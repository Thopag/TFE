
export simulation, ODE_system, stochastic_part

function Boltzmann(V, A1, V_1_2_1, k1, A2, V_1_2_2, k2) 
    return A1 / ( 1 + exp((V-V_1_2_1) / k1) ) + A2 / ( 1 + exp((V-V_1_2_2) / k2) )
end

# --------------------------- Common to all --------------------------- #

function dot_x(V, x, x_inf, tau_x; kwargs...)
    return (x_inf(V; kwargs...)-x)/tau_x(V; kwargs...)
end

# --------------------------- Include channel's equations --------------------------- #

include("channels/NaV1.3.jl")
include("channels/NaV1.7.jl")
include("channels/NaV1.8.jl")
include("channels/K_M.jl")
include("channels/K_dr.jl")
include("channels/K_AHP.jl")

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
        du[12] = 0.0
    end

    # --- ODE --- #

    du[1] = (I_ext+I_noise-I_NaV1p3-I_NaV1p7-I_NaV1p8-I_Kdr-I_Km-I_Leak-I_AHP)/C

    du[2] = dot_x(V, m3, m_inf_1_3, tau_m_1_3; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[3] = dot_x(V, h3, h_inf_1_3, tau_h_1_3; C_lido=C_lido, with_lido_shift=with_lido_shift, with_DIV0=p.with_DIV0)

    du[4] = dot_x(V, m7, m_inf_1_7, tau_m_1_7; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[5] = dot_x(V, h7, h_inf_1_7, tau_h_1_7; C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[6] = dot_x(V, m8, m_inf_1_8, tau_m_1_8; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[7] = dot_x(V, h8, h_inf_1_8, tau_h_1_8; C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[8] = dot_x(V, ndr, n_inf_K_dr, tau_n_K_dr)
    du[9] = dot_x(V, ldr, l_inf_K_dr, tau_l_K_dr)
    
    du[10] = dot_x(V, nm, n_inf_K_M, tau_n_K_M)

    du[11] = dot_x(V, z_AHP, z_AHP_inf, tau_z_AHP)

    return
end

function stochastic_part(du,u,p,t)

    sigma_noise = p.sigma_noise
    mu_noise = p.mu_noise
    tau_noise = p.tau_noise
    with_noise = p.with_noise

    du[1] = 0.0
    du[2] = 0.0
    du[3] = 0.0
    du[4] = 0.0
    du[5] = 0.0
    du[6] = 0.0
    du[7] = 0.0
    du[8] = 0.0
    du[9] = 0.0
    du[10] = 0.0
    du[11] = 0.0

    if with_noise
        du[12] = sigma_noise * sqrt(2.0 / tau_noise)
    else
        du[12] = 0.0
    end

    return

end

function simulation(u0, tspan, p)

    # -- SDE Simulation -- #
    prob = SDEProblem(ODE_system, stochastic_part, u0, tspan, p) 
    sol = solve(prob,dtmax=0.01)

    # -- ODE Simulation -- #
    # prob = ODEProblem(ODE_system, u0, tspan, p) 
    # sol = solve(prob,dtmax=0.01)

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

    return t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise
end

function ODE_system_bifurcation(u,p)

    du = similar(u)
    # --- parameters --- #

    I_ext = p.I0 + p.Excitation
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

    du[2] = dot_x(V, m3, m_inf_1_3, tau_m_1_3; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[3] = dot_x(V, h3, h_inf_1_3, tau_h_1_3; C_lido=C_lido, with_lido_shift=with_lido_shift, with_DIV0=p.with_DIV0)

    du[4] = dot_x(V, m7, m_inf_1_7, tau_m_1_7; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[5] = dot_x(V, h7, h_inf_1_7, tau_h_1_7; C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[6] = dot_x(V, m8, m_inf_1_8, tau_m_1_8; C_lido=C_lido, with_lido_shift=with_lido_shift)
    du[7] = dot_x(V, h8, h_inf_1_8, tau_h_1_8; C_lido=C_lido, with_lido_shift=with_lido_shift)

    du[8] = dot_x(V, ndr, n_inf_K_dr, tau_n_K_dr)
    du[9] = dot_x(V, ldr, l_inf_K_dr, tau_l_K_dr)
    
    du[10] = dot_x(V, nm, n_inf_K_M, tau_n_K_M)

    du[11] = dot_x(V, z_AHP, z_AHP_inf, tau_z_AHP)

    return du
end