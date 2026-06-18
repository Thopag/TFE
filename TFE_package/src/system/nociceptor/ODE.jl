
# --------------------------- Include gate's equations --------------------------- #

include("gate_variable/NaV1.3.jl")
include("gate_variable/NaV1.7.jl")
include("gate_variable/NaV1.8.jl")
include("gate_variable/K_dr.jl")
include("gate_variable/K_M.jl")
include("gate_variable/K_AHP.jl")

include("currents.jl")

# --------------------------- ODE systems --------------------------- #

function nociceptor_state(du,u,p;Iext= 0.0, Inoise=0.0)

    n       = p.nociceptor
    lido    = p.lidocaine

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

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

    Iion = 0.0
    Iion += INaV1p3(V, m3, h3, n.g_NaV1p3, n.E_Na)
    Iion += INaV1p7(V, m7, h7, n.g_NaV1p7, n.E_Na)
    Iion += INaV1p8(V, m8, h8, n.g_NaV1p8, n.E_Na)
    Iion += IK_dr(V, ndr, ldr, n.g_K_dr, n.E_K)
    Iion += IK_M(V, nM, n.g_K_M, n.E_K)
    Iion += IK_AHP(V, zAHP, n.g_K_AHP, n.E_K)
    Iion += ILeak(V, n.g_Leak, n.E_Leak)

    # --- du --- #

    du[1] = (Iext+Inoise-Iion)/n.C

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

    return
end

function ODE_system_nociceptor(du,u,p,t)

    # -- update noise -- #
    noise = p.noise
    Inoise = u[end]

    if noise.with_noise
        du[end] = - ( Inoise - noise.mu) / noise.tau
    else
        du[end] = 0.0
    end

    # -- Iext value -- #
    stim    = p.stimulation
    n       = p.nociceptor

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp) # [pA]
    Iext = Iext * (10^-6) / (n.CellArea * (10^-8))      # [µA/cm^2]

    # -- update nociceptor variables -- #
    nociceptor_state(view(du, 1:11), view(u, 1:11), p; Iext=Iext, Inoise=Inoise)
    return
end

function stochastic_system_nociceptor(du,u,p,t)

    noise = p.noise

    with_noise = noise.with_noise
    sigma_noise = noise.sigma
    mu_noise = noise.mu
    tau_noise = noise.tau

    du[:] .= 0.0

    if with_noise
        du[end] = sigma_noise * sqrt(2.0 / tau_noise)
    end
    return
end


# ----------- for bifurcation ----------- #

function bifurcation_system_nociceptor(du,u,p)

    # -- Iext value -- #
    stim    = p.stimulation
    n       = p.nociceptor

    Iext = stim.Ihold + stim.amp # [pA]
    Iext = Iext * (10^-6) / (n.CellArea * (10^-8))      # [µA/cm^2]

    # -- update nociceptor variables -- #
    nociceptor_state(view(du, 1:11), view(u, 1:11), p; Iext=Iext)
    return du
end
