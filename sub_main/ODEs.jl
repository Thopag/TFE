module ODE

using DifferentialEquations
using ..Utils
using ..Lidocaine

export simulation, ODE_system, stochastic_part

function Boltzmann(V, A1, V_1_2_1, k1, A2, V_1_2_2, k2) 
    return A1 / ( 1 + exp((V-V_1_2_1) / k1) ) + A2 / ( 1 + exp((V-V_1_2_2) / k2) )
end

# --------------------------- Common to all --------------------------- #

function dot_x(V, x, x_inf, tau_x; kwargs...)
    return (x_inf(V; kwargs...)-x)/tau_x(V; kwargs...)
end

function dot_x_DIV(V, x, x_inf, tau_x; with_DIV0 = true, kwargs...)
    return (x_inf(V;with_DIV0=with_DIV0, kwargs...)-x)/tau_x(V; with_DIV0=with_DIV0, kwargs...)
end

# --------------------------- Na_V 1.3 --------------------------- #

function alpha_m_1_3(V; lido_shift=0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp-12+lido_shift))/-15.43))
end

function alpha_h_1_3(V; with_DIV0=true, lido_shift=0)
    jp = 4.2
    if with_DIV0
        return 0.0744/(1+exp((V-(-99.76-jp+lido_shift))/11.07))
    end
    return 0.0744/(1+exp((V-(-99.76-jp+10+lido_shift))/11.07))
end

function beta_m_1_3(V; lido_shift=0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp-12+lido_shift))/14.53))
end

function beta_h_1_3(V; with_DIV0=true, lido_shift=0)
    jp = 4.2
    if with_DIV0
        return 2.54/(1+exp((V-(-7.8-jp+lido_shift))/-10.68))
    end
    return 2.54/(1+exp((V-(-7.8-jp+10+lido_shift))/-10.68))
end

# ---- #

function h_inf_1_3(V; with_DIV0=true, with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = inact_1_3_shift(C_lido)
    end
    return alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) / (alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) + beta_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift))
end

function tau_h_1_3(V; with_DIV0=true, with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) + beta_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift))
end

function m_inf_1_3(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = act_1_3_shift(C_lido)
    end
    return alpha_m_1_3(V; lido_shift=lido_shift) / (alpha_m_1_3(V; lido_shift=lido_shift) + beta_m_1_3(V; lido_shift=lido_shift))
end

function tau_m_1_3(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_m_1_3(V; lido_shift=lido_shift) + beta_m_1_3(V; lido_shift=lido_shift))
end

# --------------------------- Na_V 1.7 --------------------------- #

function alpha_m_1_7(V; lido_shift=0)
    return 10.22/(1+exp((V-(-7.19-4.2+lido_shift))/-15.43))
end

function alpha_h_1_7(V; lido_shift=0)
    return 0.0744/(1+exp((V-(-99.76-4.2+lido_shift))/11.07))
end

function beta_m_1_7(V; lido_shift=0)
    return 23.76/(1+exp((V-(-70.37-4.2+lido_shift))/14.53))
end

function beta_h_1_7(V; lido_shift=0)
    return 2.54/(1+exp((V-(-7.8-4.2+lido_shift))/-10.68))
end

# ---- #

function h_inf_1_7(V; with_original = true, C_lido=0, with_lido_shift=false)
    if !with_original
        return control_1_7_inactivation(V; C_lido=C_lido)
    end
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = inact_1_7_shift(C_lido)
    end
    return alpha_h_1_7(V; lido_shift=lido_shift) / (alpha_h_1_7(V; lido_shift=lido_shift) + beta_h_1_7(V; lido_shift=lido_shift))
end

function tau_h_1_7(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_h_1_7(V; lido_shift=lido_shift) + beta_h_1_7(V; lido_shift=lido_shift))
end

function m_inf_1_7(V; with_original = true, C_lido=0, with_lido_shift=false)
    if !with_original
        return control_1_7_activation(V; C_lido=C_lido)
    end
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = act_1_7_shift(C_lido)
    end
    return alpha_m_1_7(V; lido_shift=lido_shift) / (alpha_m_1_7(V; lido_shift=lido_shift) + beta_m_1_7(V; lido_shift=lido_shift))
end

function tau_m_1_7(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_m_1_7(V; lido_shift=lido_shift) + beta_m_1_7(V; lido_shift=lido_shift))
end

# ---- #
# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine

function control_1_7_activation(V; C_lido=0) 
    # With 100 µM lidocaine 
    # Boltzmann(V, 1.0, -23.92, -3.89, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -25.56, -3.75, 0.0, 0.0, 1.0)
end

function control_1_7_inactivation(V; C_lido=0)
    # With 100 µM lidocaine 
    # Boltzmann(V, 1.0, -79.02, 5.52, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -68.38, 4.37, 0.0, 0.0, 1.0)
end

# --------------------------- Na_V 1.8 --------------------------- #

function alpha_m_1_8(V; lido_shift=0)
    return 7.21/(1+exp((V-(0.063-5.3+lido_shift))/-7.86))
end

function alpha_h_1_8(V; lido_shift=0)
    return 1.63/(1+exp((V-(-68.5-5.3+lido_shift))/10.01))
end

function beta_m_1_8(V; lido_shift=0)
    return 7.4/(1+exp((V-(-53.06-5.3+lido_shift))/19.34))
end

function beta_h_1_8(V; lido_shift=0)
    return 0.81/(1+exp((V-(11.44-5.3+lido_shift))/-13.12))
end

# ---- #

function h_inf_1_8(V; with_original = true, C_lido=0, with_lido_shift=false)
    if !with_original
        return control_1_8_inactivation(V; C_lido=C_lido) 
    end
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = inact_1_8_shift(C_lido)
    end
    return alpha_h_1_8(V; lido_shift=lido_shift) / (alpha_h_1_8(V; lido_shift=lido_shift) + beta_h_1_8(V; lido_shift=lido_shift))
end

function tau_h_1_8(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_h_1_8(V; lido_shift=lido_shift) + beta_h_1_8(V; lido_shift=lido_shift))
end

function m_inf_1_8(V; with_original = true, C_lido=0, with_lido_shift=false)
    if !with_original
        return control_1_8_activation(V; C_lido=C_lido)
    end
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = act_1_8_shift(C_lido)
    end
    return alpha_m_1_8(V; lido_shift=lido_shift) / (alpha_m_1_8(V; lido_shift=lido_shift) + beta_m_1_8(V; lido_shift=lido_shift))
end

function tau_m_1_8(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0
    if with_lido_shift
        lido_shift = 0
    end
    return 1 / (alpha_m_1_8(V; lido_shift=lido_shift) + beta_m_1_8(V; lido_shift=lido_shift))
end

# ---- #
# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine

function control_1_8_activation(V; C_lido=0)
    # With 100 µM lidocaine
    # Boltzmann(V, 1.0, 12.32, -6.63, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, 6.24, -5.73, 0.0, 0.0, 1.0)
end

function control_1_8_inactivation(V; C_lido=0)
    # With 100 µM lidocaine
    # Boltzmann(V, 1.0, -46.81, 8.07, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -42.72, 9.05, 0.0, 0.0, 1.0)
end

# --------------------------- K_M --------------------------- #

function n_inf_K_M(V)
    return 1.0 / (1+exp(-(V-(-35))/5))
end

function tau_n_K_M(V)
    celsius = 25.0
    tadj = 3^((celsius-23.5)/10)
    return 1000.0/(3.3*(exp((V-(-35))/10)+exp(-(V+35)/10))) / tadj
end

# --------------------------- K_dr --------------------------- #

function alpha_n_K_dr(V)
    return exp(1e-3*-5*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function alpha_l_K_dr(V)
    return exp(1e-3*2*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

function beta_n_K_dr(V)
    gmn = 0.4
    return exp(1e-3*-5*gmn*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function beta_l_K_dr(V)
    gml=1.0
    return exp(1e-3*2*gml*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

# ---- #

function n_inf_K_dr(V)
    return 1/(1+alpha_n_K_dr(V))
end

function tau_n_K_dr(V)
    q10 = 3^((25-30)/10)
    return beta_n_K_dr(V)/(q10*0.03*(1+alpha_n_K_dr(V)))
end

function l_inf_K_dr(V)
    return 1/(1+alpha_l_K_dr(V))
end

function tau_l_K_dr(V)
    q10 = 3^((25-30)/10)
    return beta_l_K_dr(V)/(q10*0.001*(1 + alpha_l_K_dr(V)))
end

# --------------------------- AHP --------------------------- #

function z_AHP_inf(V)
    beta_z_AHP = 5
    gamma_z =  4
    return 1 / ( 1 + exp( (beta_z_AHP - V)/gamma_z ) ) 
end

function tau_z_AHP(V)
    return 100
end

# --------------------------- Simulation function --------------------------- #

function ODE_system(du,u,p,t)

    # --- parameters --- #

    I_ext = p.I0 + pulse(t, p.stim_on, p.stim_off) * p.Excitation
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

    with_original = p.with_original
    with_lido_shift = p.with_lido_shift

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

    I_noise = u[12]

    # --- currents --- #

    I_NaV1p3 = g_nav1p3 * (m3^3) * h3 * (V-E_Na)
    I_NaV1p7 = g_nav1p7 * (m7^3) * h7 * (V-E_Na)
    I_NaV1p8 = g_nav1p8 * (m8^3) * h8 * (V-E_Na)
    I_Kdr = g_Kdr * (ndr^3) * ldr * (V-E_k)
    I_Km = g_Km*nm * (V-E_k)
    I_AHP = g_AHP * (z_AHP^1) * (V-E_k)
    I_Leak = g_Leak * (V-E_Leak)
    
    if with_noise
        du[12] = - ( I_noise - mu_noise) / tau_noise
    else
        du[12] = 0
    end

    # --- ODE --- #

    du[1] = (I_ext+I_noise-I_NaV1p3-I_NaV1p7-I_NaV1p8-I_Kdr-I_Km-I_Leak-I_AHP)/C

    du[2] = dot_x(V, m3, m_inf_1_3, tau_m_1_3; with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[3] = dot_x_DIV(V, h3, h_inf_1_3, tau_h_1_3; with_DIV0=p.with_DIV0, with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[4] = dot_x(V, m7, m_inf_1_7, tau_m_1_7; with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[5] = dot_x(V, h7, h_inf_1_7, tau_h_1_7; with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[6] = dot_x(V, m8, m_inf_1_8, tau_m_1_8; with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[7] = dot_x(V, h8, h_inf_1_8, tau_h_1_8; with_original=with_original, C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[8] = dot_x(V, ndr, n_inf_K_dr, tau_n_K_dr)
    du[9] = dot_x(V, ldr, l_inf_K_dr, tau_l_K_dr)
    
    du[10] = dot_x(V, nm, n_inf_K_M, tau_n_K_M)

    du[11] = dot_x(V, z_AHP, z_AHP_inf, tau_z_AHP)

    ##################
    q10=3^((25-30)/10)
    ninf = alpha_n_K_dr(V)/(beta_n_K_dr(V)+alpha_n_K_dr(V))
    taun = 1/(q10*0.03*(beta_n_K_dr(V)+alpha_n_K_dr(V)))

    linf = alpha_l_K_dr(V)/(beta_l_K_dr(V)+alpha_l_K_dr(V))
    taul = 1/(q10*0.001*(beta_l_K_dr(V)+alpha_l_K_dr(V)))

    du[13] = (ninf - u[13])/taun
    du[14] = (linf - u[14])/taul
    ##################

    return
end

function stochastic_part(du,u,p,t)

    sigma_noise = p.sigma_noise
    mu_noise = p.mu_noise
    tau_noise = p.tau_noise
    with_noise = p.with_noise

    du[1] = 0
    du[2] = 0
    du[3] = 0
    du[4] = 0
    du[5] = 0
    du[6] = 0
    du[7] = 0
    du[8] = 0
    du[9] = 0
    du[10] = 0
    du[11] = 0
    du[13] = 0
    du[14] = 0

    if with_noise
        du[12] = sigma_noise * sqrt(2 / tau_noise)
    else
        du[12] = 0
    end

    return

end

function simulation(u0, tspan, p)

    # -- SDE Simulation -- #
    prob = SDEProblem(ODE_system, stochastic_part, u0, tspan, p) 
    sol = solve(prob,dtmax=0.01)

    # -- Simulation results -- #
    t = sol.t
    V      = sol[1, :]
    m3     = sol[2, :]
    h3     = sol[3, :]
    m7     = sol[4, :]
    h7     = sol[5, :]
    m8     = sol[6, :]
    h8     = sol[7, :]
    ndr    = sol[8, :]
    ldr    = sol[9, :]
    nm     = sol[10, :]
    z_AHP  = sol[11, :]
    Inoise = sol[12, :]
    n_test  = sol[13, :]
    l_test = sol[14, :]

    return t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test
end

precompile(simulation, (Vector{Float64}, Tuple{Float64, Float64}, Parameters{Float64}))

end