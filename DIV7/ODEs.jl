module ODE_DIV7

using DifferentialEquations
using ..Utils

export simulation, ODE_system, stochastic_part

# --------------------------- Common to Na_V 1.7, Na_V 1.3, Na_V 1.8 --------------------------- #

function dot_m(V, m, alpha, beta)
    return alpha(V)*(1-m) - m*beta(V)
end

function dot_h(V, h, alpha, beta)
    return alpha(V)*(1-h) - h*beta(V)
end

# --------------------------- Na_V 1.3 --------------------------- #

function alpha_m_1_3(V)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp-12))/-15.43))
end

function alpha_h_1_3(V)
    jp = 4.2
    return 0.0744/(1+exp((V-(-99.76-jp+10))/11.07)) # +10 is different than DIV0
end

function beta_m_1_3(V)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp-12))/14.53))
end

function beta_h_1_3(V)
    jp = 4.2
    return 2.54/(1+exp((V-(-7.8-jp+10))/-10.68)) # +10 is different than DIV0
end

# ---- #

function h_inf_1_3(V)
    return alpha_h_1_3(V) / (alpha_h_1_3(V) + beta_h_1_3(V))
end

function tau_h_1_3(V)
    return 1 / (alpha_h_1_3(V) + beta_h_1_3(V))
end

function m_inf_1_3(V)
    return alpha_m_1_3(V) / (alpha_m_1_3(V) + beta_m_1_3(V))
end

function tau_m_1_3(V)
    return 1 / (alpha_m_1_3(V) + beta_m_1_3(V))
end

# --------------------------- Na_V 1.7 --------------------------- #

function alpha_m_1_7(V)
    return 10.22/(1+exp((V-(-7.19-4.2))/-15.43))
end

function alpha_h_1_7(V)
    return 0.0744/(1+exp((V-(-99.76-4.2))/11.07))
end

function beta_m_1_7(V)
    return 23.76/(1+exp((V-(-70.37-4.2))/14.53))
end

function beta_h_1_7(V)
    return 2.54/(1+exp((V-(-7.8-4.2))/-10.68))
end

# ---- #

function h_inf_1_7(V)
    return alpha_h_1_7(V) / (alpha_h_1_7(V) + beta_h_1_7(V))
end

function tau_h_1_7(V)
    return 1 / (alpha_h_1_7(V) + beta_h_1_7(V))
end

function m_inf_1_7(V)
    return alpha_m_1_7(V) / (alpha_m_1_7(V) + beta_m_1_7(V))
end

function tau_m_1_7(V)
    return 1 / (alpha_m_1_7(V) + beta_m_1_7(V))
end

# --------------------------- Na_V 1.8 --------------------------- #

function alpha_m_1_8(V)
    return 7.21/(1+exp((V-(0.063-5.3))/-7.86))
end

function alpha_h_1_8(V)
    return 1.63/(1+exp((V-(-68.5-5.3))/10.01))
end

function beta_m_1_8(V)
    return 7.4/(1+exp((V-(-53.06-5.3))/19.34))
end

function beta_h_1_8(V)
    return 0.81/(1+exp((V-(11.44-5.3))/-13.12))
end

# ---- #

function h_inf_1_8(V)
    return alpha_h_1_8(V) / (alpha_h_1_8(V) + beta_h_1_8(V))
end

function tau_h_1_8(V)
    return 1 / (alpha_h_1_8(V) + beta_h_1_8(V))
end

function m_inf_1_8(V)
    return alpha_m_1_8(V) / (alpha_m_1_8(V) + beta_m_1_8(V))
end

function tau_m_1_8(V)
    return 1 / (alpha_m_1_8(V) + beta_m_1_8(V))
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

function dot_n_K_M(V, n)
    return (n_inf_K_M(V)-n)/tau_n_K_M(V)
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

# ---- #

function dot_n_K_dr(V, n)
    return (n_inf_K_dr(V)-n)/tau_n_K_dr(V)
end

function dot_l_K_dr(V, n)
    return (l_inf_K_dr(V)-n)/tau_l_K_dr(V)
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

function dot_z_AHP(V, z) 
    return ( z_AHP_inf(V) - z) / tau_z_AHP(V)
end

# --------------------------- Simulation function --------------------------- #

function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

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

    du[2] = dot_m(V, m3, alpha_m_1_3, beta_m_1_3)
    du[3] = dot_h(V, h3, alpha_h_1_3, beta_h_1_3)

    du[4] = dot_m(V, m7, alpha_m_1_7, beta_m_1_7)
    du[5] = dot_h(V, h7, alpha_h_1_7, beta_h_1_7)

    du[6] = dot_m(V, m8, alpha_m_1_8, beta_m_1_8)
    du[7] = dot_h(V, h8, alpha_h_1_8, beta_h_1_8)
    
    du[8] = dot_n_K_dr(V, ndr)
    du[9] = dot_l_K_dr(V, ldr)
    
    du[10] = dot_n_K_M(V, nm)

    du[11] = dot_z_AHP(V, z_AHP)

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