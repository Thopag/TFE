export make_bifurcation, init_bifurcation, iteration_bifurcation

function ODE_system_bifurcation(u,p)

    du = similar(u)

    stim    = p.stimulation
    n       = p.nociceptor
    pn      = p.projection_neuron
    lido    = p.lidocaine
    noise   = p.noise

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

    # ------------------------------------------ Nociceptor ------------------------------------------ #

    # --- variables --- #

    V       = u[1]
    m3      = u[2]
    h3      = u[3]
    m7      = u[4]
    h7      = u[5]
    m8      = u[6]
    h8      = u[7]
    ndr     = u[8]
    ldr     = u[9]
    nM      = u[10]
    zAHP    = u[11]

    # --- currents --- #

    Excitation  = ((stim.amp * (10^-6))     / (n.CellArea * (10^-8))) 
    I0          = ((stim.Ihold * (10^-6))   / (n.CellArea * (10^-8))) 
    Iext    = I0 + Excitation

    INaV1p3 = n.g_NaV1p3    * (m3^3) * h3   * (V-n.E_Na)
    INaV1p7 = n.g_NaV1p7    * (m7^3) * h7   * (V-n.E_Na)
    INaV1p8 = n.g_NaV1p8    * (m8^3) * h8   * (V-n.E_Na)
    IK_dr   = n.g_K_dr      * (ndr^3) * ldr * (V-n.E_K)
    IK_M    = n.g_K_M       * nM            * (V-n.E_K)
    IK_AHP  = n.g_K_AHP     * (zAHP^1)      * (V-n.E_K)
    ILeak   = n.g_Leak                      * (V-n.E_Leak)

    # --- ODE --- #

    du[1] = (Iext-INaV1p3-INaV1p7-INaV1p8-IK_dr-IK_M-IK_AHP-ILeak)/n.C

    du[2] = dot_m3(V, m3)
    du[3] = dot_h3(V, h3; C_lido=C_lido, shift=lido.shift_h3, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    du[4] = dot_m7(V, m7)
    du[5] = dot_h7(V, h7; C_lido=C_lido, shift=lido.shift_h7, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    du[6] = dot_m8(V, m8; C_lido=C_lido, shift=lido.shift_m8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    du[7] = dot_h8(V, h8; C_lido=C_lido, shift=lido.shift_h8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    du[8] = dot_ndr(V, ndr)
    du[9] = dot_ldr(V, ldr)
    
    du[10] = dot_nM(V, nM)

    du[11] = dot_zAHP(V, zAHP)

    return du
end

function make_bifurcation(p_model, u0, lens_param, p_min, p_max)

    prob = BifurcationProblem(ODE_system_bifurcation, u0, p_model, lens_param, 
        record_from_solution = (x, p; k...) -> x[:])

    step_scaling = 100
    opts = ContinuationPar(
        p_min = p_min, 
        p_max = p_max,
        max_steps = 10000*step_scaling ,
        dsmin = 0.01/step_scaling , 
        ds = 0.1/step_scaling ,
        dsmax = 1/step_scaling ,
        detect_bifurcation = 3,
        detect_event = 0
    )
    br = continuation(prob, PALC(), opts)

    return br
end

function get_limit_cycle(u, bif_param, p_model; inter_value=2.5, max_inter=20.0)

    duration = 2000.0
    u0 = copy(u)
    i_p_stim = stimulation_parameter(bif_param; on=0.0, length=duration)
    i_p_model = model_parameter(i_p_stim, p_model.nociceptor; lidocaine=p_model.lidocaine)

    max = NaN64
    min = NaN64

    # check if it is not just an instable point
    # In the futur can use an extra arg stability, instead of it !!!!!!!!
    sol = simulation(u, (0.0, duration), i_p_model)
    pattern = get_pattern(sol, i_p_stim)
    if pattern == 4
        return min, max
    end

    finded_min = false
    finded_max = false
    for i in inter_value:inter_value:max_inter*inter_value
        print("\rProgress: $(round((i/(max_inter*inter_value))*100, digits=2)) % - $(round(bif_param, digits=2))\e[K")

        # idx=1 because we are focused on V
        u0[1] = u[1] - i
        sol = simulation(u0, (0.0, duration), i_p_model)
        pattern = get_pattern(sol, i_p_stim)
        if pattern == 4 && !finded_min
            min = u0[1]
            finded_min = true
        end

        u0[1] = u[1] + i
        sol = simulation(u0, (0.0, duration), i_p_model)
        pattern = get_pattern(sol, i_p_stim)
        if pattern == 4 && !finded_max
            max = u0[1]
            finded_max = true
        end

        if finded_max && finded_min
            print("\r")
            return min, max
        end
    end
    print("\r")
    return min, max
end

function search_all_limit_cycle(br, p_model; bif_param_incr=7.5)

    println("Start limit cycle searching")
    println()
    VEC_u = br.branch.x 
    VEC_bif_param = br.branch.param
    init_L = length(VEC_bif_param)

    VEC_min = Float64[]
    VEC_max = Float64[]
    VEC_plot_bif_param = eltype(VEC_bif_param)[]

    stop = false
    while !stop
        L = length(VEC_bif_param)
        print("\e[1AProgress: $(round((1-(L/init_L))*100, digits=2)) %\e[K\n")
        start_val = VEC_bif_param[1]
        idx = findfirst(x -> abs(x - start_val) >= bif_param_incr, VEC_bif_param)

        if (isnothing(idx)) || (idx == length(VEC_bif_param))
            stop = true
        else
            if VEC_bif_param[idx] >= 0.0
                min, max = get_limit_cycle(VEC_u[idx], VEC_bif_param[idx], p_model)
                push!(VEC_min, min)
                push!(VEC_max, max)
                push!(VEC_plot_bif_param, VEC_bif_param[idx])
            end
            VEC_u = VEC_u[(idx+1):end]
            VEC_bif_param = VEC_bif_param[(idx+1):end]
        end
    end
    println("End limit cycle searching\e[K")

    return VEC_min, VEC_max, VEC_plot_bif_param
end


function init_bifurcation(param_label, p_min, p_max, reds, greens, greys; xlimits=:native)

    if length(reds) > 1
        color_specialpoint = Dict{Symbol, Vector{RGB{Float64}}}(:hopf => reds, :bp => greens, :endpoint => greys)
    else
        color_specialpoint = Dict{Symbol, Vector{Symbol}}(:hopf => [:red], :bp => [:green], :endpoint => [:grey])
    end
    label_specialpoint = Dict{Symbol, String}(:hopf => "Hopf", :bp => "Branch Point", :endpoint => "End Point")

    xticks = p_min:30:p_max

    plt = plot(xlabel=param_label, ylabel=" Voltage (mV)", legendfontsize=7, xticks=xticks, xlims=xlimits, legend = :bottomright)

    for ((symbol_type, colors), (_, label)) in zip(color_specialpoint, label_specialpoint)
        scatter!(plt, [], [], label=label, c=colors[(end ÷ 2) + 1])
    end
    return plt, color_specialpoint
end

function iteration_bifurcation(plt, i, p_model, u0, lens_param, p_min, p_max, 
                                                    inter_label, color_specialpoint, reds, greens, greys)
    
    plot!(plt, [], [], label=inter_label, color=greys[i], alpha=1)
    br = make_bifurcation(p_model, u0, lens_param, p_min, p_max)

    # ----  Plot result ---- #
    V =  [x[1] for x in br.branch.x]
    VEC_bif_param = br.branch.param
    VEC_stability = br.branch.stable

    color_stability = [reds[i], greens[i]]
    linestyle_stability = [:dash, :solid]

    start_idx = 1
    # Add special point and trajectories
    for specialpoint in br.specialpoint
        sp_idx = specialpoint.idx

        plot!(plt, VEC_bif_param[start_idx:sp_idx] , V[start_idx:sp_idx], c=color_stability[VEC_stability[start_idx] + 1], linestyle=linestyle_stability[VEC_stability[start_idx] + 1] 
                                                        ,alpha=0.7, label="", linewidth = 1.0)
        start_idx = sp_idx + 1

        symbol_type = specialpoint.type
        colors = get(color_specialpoint, symbol_type, :blue)
        scatter!(plt, [VEC_bif_param[sp_idx]], [V[sp_idx]], label="", c=colors[i], markersize = 4, alpha=1)
    end

    VEC_min, VEC_max, VEC_plot_bif_param = search_all_limit_cycle(br, p_model)

    plot!(plt, VEC_plot_bif_param, VEC_min, color= :purple, marker=:circle, markersize=2, linealpha=0.5, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0)
    plot!(plt, VEC_plot_bif_param, VEC_max, color= :purple, marker=:circle, markersize=2, linealpha=0.5, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0)
    return br
end