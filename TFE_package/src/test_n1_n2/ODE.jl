

function ODE_system_test_n1_n2(du,u,p,t)

    # -- update noise -- #
    noise = p.noise
    Inoise = u[end]

    if noise.with_noise
        du[end] = - ( Inoise - noise.mu) / noise.tau
    else
        du[end] = 0.0
    end

    # -- Iext value on nociceptor -- #
    stim     = p.stimulation
    pn       = p.projection_neuron

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp) # [pA]
    Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    # -- update n1 variables -- #
    projection_neuron_state(view(du, 1:11), view(u, 1:11), p; Iext=Iext)

    # -- update synapse -- #
    V_post_syn = u[12]
    Isyn, ICa_from_syn = synapse_state(view(du, 17:24),view(u, 17:24),p,V_post_syn)

    # -- update n2 variables -- #
    projection_neuron_state(view(du, 12:16), view(u, 12:16), p; Isyn=Isyn, ICa_from_syn=ICa_from_syn)
    return
end