
export simulation, ODE_system, stochastic_part

function Boltzmann(V, A1, V_1_2_1, k1, A2, V_1_2_2, k2) 
    return A1 / ( 1 + exp((V-V_1_2_1) / k1) ) + A2 / ( 1 + exp((V-V_1_2_2) / k2) )
end

# --------------------------- Common to all --------------------------- #

function dot_x(V, x, x_inf, tau_x; kwargs...)
    return (x_inf(V; kwargs...)-x)/tau_x(V; kwargs...)
end

# --------------------------- Include channel's equations --------------------------- #

include("channels/nociceptor/NaV1.3.jl")
include("channels/nociceptor/NaV1.7.jl")
include("channels/nociceptor/NaV1.8.jl")
include("channels/nociceptor/K_M.jl")
include("channels/nociceptor/K_dr.jl")
include("channels/nociceptor/K_AHP.jl")

include("channels/projection_neuron/Ca_L.jl")
include("channels/projection_neuron/K_ir.jl")
include("channels/projection_neuron/K_M.jl")

# --------------------------- Simulation function --------------------------- #

function ODE_system(du,u,p,t)

    stim    = p.stimulation
    n       = p.nociceptor
    pn      = p.projection_neuron
    lido    = p.lidocaine
    noise   = p.noise

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

    Inoise = u[18]

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
    Iext    = I0 + pulse(t, stim.on, stim.off) * Excitation

    INaV1p3 = n.g_NaV1p3    * (m3^3) * h3   * (V-n.E_Na)
    INaV1p7 = n.g_NaV1p7    * (m7^3) * h7   * (V-n.E_Na)
    INaV1p8 = n.g_NaV1p8    * (m8^3) * h8   * (V-n.E_Na)
    IK_dr   = n.g_K_dr      * (ndr^3) * ldr * (V-n.E_K)
    IK_M    = n.g_K_M       * nM            * (V-n.E_K)
    IK_AHP  = n.g_K_AHP     * (zAHP^1)      * (V-n.E_K)
    ILeak   = n.g_Leak                      * (V-n.E_Leak)

    # --- ODE --- #

    du[1] = (Iext+Inoise-INaV1p3-INaV1p7-INaV1p8-IK_dr-IK_M-IK_AHP-ILeak)/n.C

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

    # ------------------------------------------ Projection neuron ------------------------------------------ #

    # --- variables --- #

    V_pn    = u[12]
    mL      = u[13]
    hL      = u[14]
    Ca_i    = u[15]
    mir     = u[16]
    mM      = u[17]

    # --- currents --- #

    Inoci = (V >= -5.0) * pn.nociceptor_input  # TO CHANGE

    ICa_L   = pn.p_Ca_L * (mL^2) * hL * GHK(V_pn, Ca_i)
    IK_ir   = pn.g_K_ir * mir         * (V_pn - pn.E_K)
    IK_M_pn = pn.g_K_M  * mM          * (V_pn - pn.E_K)
    ILeak_pn = pn.g_Leak              * (V_pn - pn.E_Leak)

    # --- ODE --- #

    du[12] = (Inoci-ICa_L-IK_ir-IK_M_pn-ILeak_pn)/pn.C

    du[13] = dot_mL(V_pn, mL)
    du[14] = dot_hL(V_pn, hL)
    du[15] = dot_Ca_i(Ca_i, ICa_L)

    du[16] = dot_mir(V_pn, mir)

    du[17] = dot_mM(V_pn, mM)

    # -------------------- noise -------------------- #

    if noise.with_noise
        du[18] = - ( Inoise - noise.mu) / noise.tau
    else
        du[18] = 0.0
    end

    return
end

function stochastic_part(du,u,p,t)

    noise = p.noise

    with_noise = noise.with_noise
    sigma_noise = noise.sigma
    mu_noise = noise.mu
    tau_noise = noise.tau

    du[1:17] .= 0.0

    if with_noise
        du[18] = sigma_noise * sqrt(2.0 / tau_noise)
    else
        du[18] = 0.0
    end

    return
end

struct Solution
    t::Vector{Float64}
    V::Vector{Float64}
    m3::Vector{Float64}
    h3::Vector{Float64}
    m7::Vector{Float64}
    h7::Vector{Float64}
    m8::Vector{Float64}
    h8::Vector{Float64}
    ndr::Vector{Float64}
    ldr::Vector{Float64}
    nM::Vector{Float64}
    zAHP::Vector{Float64}
    V_pn::Vector{Float64}
    mL::Vector{Float64}
    hL::Vector{Float64}
    Ca_i::Vector{Float64}
    mir::Vector{Float64}
    mM::Vector{Float64}
    Inoise::Vector{Float64}
end

function simulation(u0, tspan, p)

    # -- SDE Simulation -- #
    prob = SDEProblem(ODE_system, stochastic_part, u0, tspan, p) 
    sol = solve(prob,dtmax=0.01, maxiters=1e7)

    # -- ODE Simulation -- #
    # prob = ODEProblem(ODE_system, u0, tspan, p) 
    # sol = solve(prob,dtmax=0.01)

    # -- Simulation results -- #
    t      = sol.t
    V      = sol[1, :]
    m3     = sol[2, :]
    h3     = sol[3, :]
    m7     = sol[4, :]
    h7     = sol[5, :]
    m8     = sol[6, :]
    h8     = sol[7, :]
    ndr    = sol[8, :]
    ldr    = sol[9, :]
    nM     = sol[10, :]
    zAHP  = sol[11, :]

    V_pn    = sol[12, :]
    mL      = sol[13, :]
    hL      = sol[14, :]
    Ca_i    = sol[15, :]
    mir     = sol[16, :]
    mM      = sol[17, :]

    Inoise = sol[18, :]

    solution = Solution(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nM,zAHP, 
                            V_pn,mL,hL,Ca_i,mir,mM,
                            Inoise)

    return solution
end
