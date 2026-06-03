export make_bifurcation, init_bifurcation, iteration_bifurcation

function ODE_system_bifurcation(u,p)

    du = similar(u)

    stim = p.stimulation
    noise = p.noise
    n = p.nociceptor
    lido = p.lidocaine

    # --- parameters --- #

    Excitation = ((stim.amp * (10^-6)) / (n.CellArea * (10^-8))) 
    I0         = ((stim.Ihold * (10^-6)) / (n.CellArea * (10^-8))) 

    Iext = I0 + Excitation

    C = n.C

    g_NaV1p3 = n.g_NaV1p3
    g_NaV1p7 = n.g_NaV1p7
    g_NaV1p8 = n.g_NaV1p8
    E_Na = n.E_Na

    g_K_dr = n.g_K_dr
    g_K_M = n.g_K_M
    g_K_AHP = n.g_K_AHP
    E_K = n.E_K

    g_Leak = n.g_Leak
    E_Leak = n.E_Leak

    with_noise = noise.with_noise
    sigma_noise = noise.sigma
    mu_noise = noise.mu
    tau_noise = noise.tau

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

    # --- variables --- #

    V = u[1]

    m3 = u[2]
    h3 = u[3]

    m7 = u[4]
    h7 = u[5]

    m8 = u[6]
    h8 = u[7]

    ndr = u[8]
    ldr = u[9]

    nM = u[10]

    zAHP = u[11]

    # --- currents --- #

    INaV1p3 = g_NaV1p3 * (m3^3) * h3 * (V-E_Na)
    INaV1p7 = g_NaV1p7 * (m7^3) * h7 * (V-E_Na)
    INaV1p8 = g_NaV1p8 * (m8^3) * h8 * (V-E_Na)
    IK_dr = g_K_dr * (ndr^3) * ldr * (V-E_K)
    IK_M = g_K_M*nM * (V-E_K)
    IK_AHP = g_K_AHP * (zAHP^1) * (V-E_K)
    ILeak = g_Leak * (V-E_Leak)

    # --- ODE --- #

    du[1] = (Iext-INaV1p3-INaV1p7-INaV1p8-IK_dr-IK_M-ILeak-IK_AHP)/C

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
    bif_param = br.branch.param
    stability = br.branch.stable

    #color_stability = [:red, :blue]
    color_stability = [reds[i], greens[i]]
    linestyle_stability = [:dash, :solid]

    # plot!(plt, bif_param , V, c=color_stability[stability .+ 1], linestyle=linestyle_stability[stability .+ 1], label="", linewidth = 1.0)

    start_idx = 1
    # Add special point and trajectories
    for specialpoint in br.specialpoint
        sp_idx = specialpoint.idx

        plot!(plt, bif_param[start_idx:sp_idx] , V[start_idx:sp_idx], c=color_stability[stability[start_idx] + 1], linestyle=linestyle_stability[stability[start_idx] + 1] 
                                                        ,alpha=0.7, label="", linewidth = 1.0)
        start_idx = sp_idx + 1

        symbol_type = specialpoint.type
        colors = get(color_specialpoint, symbol_type, :blue)
        scatter!(plt, [bif_param[sp_idx]], [V[sp_idx]], label="", c=colors[i], markersize = 4, alpha=1)
    end
    return br
end