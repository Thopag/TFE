

function old_projection_neuron_state(du,u,p; Iext=0.0, Isyn=0.0, ICa_from_syn=0.0)

    pn   = p.projection_neuron

    # --- variables --- #

    V       = u[1]
    mNa     = u[2]
    hNa     = u[3]
    mdr     = u[4]
    Ca_i    = u[11]

    # --- currents --- #

    Iion = 0.0
    Iion += INa(V, mNa, hNa, pn.g_Na, pn.E_Na)
    Iion += IK_dr_pn(V, mdr, pn.g_K_dr, pn.E_K)
    Iion += ILeak_pn(V, pn.g_Leak, pn.E_Leak)

    # --- du --- #

    du[1] = (Iext-Iion-Isyn)/pn.C

    du[2] = dot_mNa(V, mNa)
    du[3] = dot_hNa(V, hNa)
    du[4] = dot_mdr(V, mdr)

    du[11] = dot_Ca_i(Ca_i, 0.0+ICa_from_syn, pn)

    return
end

function ODE_system_test_n1_n2(du,u,p,t)

    idx = p.idx

    # -- Iext value on nociceptor -- #
    stim     = p.stimulation
    pn       = p.projection_neuron

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp) # [pA]
    Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    # -- update nociceptor variables -- #
    old_projection_neuron_state(view(du, idx.n), view(u, idx.n), p; Iext=Iext)

    # -- update synapse -- #
    V_post_syn = u[idx.pn[1]]
    Isyn, ICa_from_syn = synapse_state(view(du, idx.s),view(u, idx.s),p,V_post_syn)

    # -- update projection_neuron variables -- #
    old_projection_neuron_state(view(du, idx.pn), view(u, idx.pn), p; Isyn=Isyn, ICa_from_syn=ICa_from_syn)
    return
end