# --------------------------- Include gate's equations --------------------------- #

include("gate_variable/AMPA.jl")
include("gate_variable/NMDA.jl")

include("currents.jl")

# --------------------------- ODE systems --------------------------- #

function synapse_state(du,u,p,V)

    s = p.synapse

    # --- variables --- #

    A_NMDA   = u[1]
    B_NMDA   = u[2]
    Use_NMDA = u[3]
    P_NMDA   = u[4] 
    A_AMPA   = u[5] 
    B_AMPA   = u[6] 
    Use_AMPA = u[7]
    P_AMPA   = u[8]

    # --- currents --- #

    tmp = INMDA(V, A_NMDA, B_NMDA, s.g_NMDA, s.E_NMDA)

    Isyn = 0.0
    Isyn += tmp
    Isyn += IAMPA(V, A_AMPA, B_AMPA, s.g_AMPA, s.E_AMPA)

    ICa_from_syn = tmp * s.ratio

    # --- du --- #

    du[1] = dot_A_NMDA(A_NMDA, s.tau_rise_NMDA)
    du[2] = dot_B_NMDA(B_NMDA, s.tau_decay_NMDA)
    du[3] = dot_Use_NMDA(Use_NMDA, s.tau_fac_NMDA)
    du[4] = dot_P_NMDA(P_NMDA, s.tau_rec_NMDA)
    du[5] = dot_A_AMPA(A_AMPA, s.tau_rise_AMPA)
    du[6] = dot_B_AMPA(B_AMPA, s.tau_decay_AMPA)
    du[7] = dot_Use_AMPA(Use_AMPA, s.tau_fac_AMPA)
    du[8] = dot_P_AMPA(P_AMPA, s.tau_rec_AMPA)

    return Isyn, ICa_from_syn
end

function ODE_system_with_synapse(du,u,p,t)

    # -- update noise -- #
    noise = p.noise
    Inoise = u[end]

    if noise.with_noise
        du[end] = - ( Inoise - noise.mu) / noise.tau
    else
        du[end] = 0.0
    end

    # -- Iext value on nociceptor -- #
    stim    = p.stimulation
    n       = p.nociceptor

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp) # [pA]
    Iext = Iext * (10^-6) / (n.CellArea * (10^-8))      # [µA/cm^2]

    # -- update nociceptor variables -- #
    nociceptor_state(view(du, 1:11), view(u, 1:11), p, Iext; Inoise=Inoise)

    # -- update synapse -- #
    V_post_syn = u[12]
    Isyn, ICa_from_syn = synapse_state(view(du, 17:24),view(u, 17:24),p,V_post_syn)

    # -- update projection_neuron variables -- #
    projection_neuron_state(view(du, 12:16), view(u, 12:16), p; Isyn=Isyn, ICa_from_syn=ICa_from_syn)
    return
end

function stochastic_system_with_synapse(du,u,p,t)

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