export make_bifurcation, init_bifurcation, iteration_bifurcation

function ODE_system_bifurcation(u,p)

    du = similar(u)
    # --- parameters --- #

    Excitation = ((p.amp * (10^-6)) / (p.CellArea * (10^-8))) 
    I_ext = p.I0 + Excitation
    C = p.C

    g_nav1p3 = p.g_nav1p3
    g_nav1p7 = p.g_nav1p7
    g_nav1p8 = p.g_nav1p8
    E_Na = p.E_Na

    g_Kdr = p.g_Kdr
    g_Km = p.g_Km
    g_AHP = p.g_AHP
    E_k = p.E_k

    g_Leak = p.g_Leak
    E_Leak = p.E_Leak

    sigma_noise = p.sigma_noise
    mu_noise = p.mu_noise
    tau_noise = p.tau_noise

    with_noise = p.with_noise

    C_lido = p.C_lidocaine

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

    nm = u[10]

    z_AHP = u[11]

    # --- currents --- #

    I_NaV1p3 = g_nav1p3 * (m3^3) * h3 * (V-E_Na)
    I_NaV1p7 = g_nav1p7 * (m7^3) * h7 * (V-E_Na)
    I_NaV1p8 = g_nav1p8 * (m8^3) * h8 * (V-E_Na)
    I_Kdr = g_Kdr * (ndr^3) * ldr * (V-E_k)
    I_Km = g_Km*nm * (V-E_k)
    I_AHP = g_AHP * (z_AHP^1) * (V-E_k)
    I_Leak = g_Leak * (V-E_Leak)

    # --- ODE --- #

    du[1] = (I_ext-I_NaV1p3-I_NaV1p7-I_NaV1p8-I_Kdr-I_Km-I_Leak-I_AHP)/C

    du[2] = dot_x(V, m3, m_inf_1_3, tau_m_1_3; C_lido=C_lido)
    du[3] = dot_x(V, h3, h_inf_1_3, tau_h_1_3; C_lido=C_lido)

    du[4] = dot_x(V, m7, m_inf_1_7, tau_m_1_7; C_lido=C_lido)
    du[5] = dot_x(V, h7, h_inf_1_7, tau_h_1_7; C_lido=C_lido)

    du[6] = dot_x(V, m8, m_inf_1_8, tau_m_1_8; C_lido=C_lido)
    du[7] = dot_x(V, h8, h_inf_1_8, tau_h_1_8; C_lido=C_lido)

    du[8] = dot_x(V, ndr, n_inf_K_dr, tau_n_K_dr)
    du[9] = dot_x(V, ldr, l_inf_K_dr, tau_l_K_dr)
    
    du[10] = dot_x(V, nm, n_inf_K_M, tau_n_K_M)

    du[11] = dot_x(V, z_AHP, z_AHP_inf, tau_z_AHP)

    return du
end

function make_bifurcation(param_init, u0, lens_param, p_min, p_max)

    prob = BifurcationProblem(ODE_system_bifurcation, u0, param_init, lens_param, 
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

function iteration_bifurcation(plt, i, param_init, u0, lens_param, p_min, p_max, 
                                                    inter_label, color_specialpoint, reds, greens, greys)
    
    plot!(plt, [], [], label=inter_label, color=greys[i], alpha=1)
    br = make_bifurcation(param_init, u0, lens_param, p_min, p_max)

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