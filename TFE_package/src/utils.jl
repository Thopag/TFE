export give_currents

function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

# --------------------------- Get Currents --------------------------- #

struct Current{T}
    INaV1p3::T
    INaV1p7::T
    INaV1p8::T
    IK_dr::T
    IK_M::T
    IK_AHP::T
    ILeak::T
    Iext::T
    ICa_L::T
    IK_ir::T
    IK_M_pn::T
    ILeak_pn::T
    Inoci::T
    Inoise::T
    dV_dt::T
end

function give_currents(sol, p_model)

    # ---- #
    n = p_model.nociceptor
    stim = p_model.stimulation
    V = sol.V

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

    Excitation = ((stim.amp * (10^-6)) / (n.CellArea * (10^-8))) 
    I0         = ((stim.Ihold * (10^-6)) / (n.CellArea * (10^-8))) 
    Iext = I0 .+ pulse.(sol.t, stim.on, stim.off) .* Excitation

    INaV1p3 = g_NaV1p3 .* (sol.m3.^3) .* sol.h3 .* (V .- E_Na)
    INaV1p7 = g_NaV1p7 .* (sol.m7.^3) .* sol.h7 .* (V .- E_Na)
    INaV1p8 = g_NaV1p8 .* (sol.m8.^3) .* sol.h8 .* (V .- E_Na)
    IK_dr = g_K_dr .* (sol.ndr.^3) .* sol.ldr .* (V .- E_K)
    IK_M = g_K_M .* sol.nM .* (V .- E_K)
    IK_AHP = g_K_AHP .* (sol.zAHP.^1) .* (V .- E_K)
    ILeak = g_Leak .* (V .- E_Leak)
    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IK_dr .- IK_M .- ILeak .- IK_AHP) ./ n.C

    # ---- #
    pn      = p_model.projection_neuron
    V_pn = sol.V_pn

    Inoci = (V .>= -5.0) .* pn.nociceptor_input

    ICa_L   = pn.p_Ca_L .* (sol.mL.^2) .* sol.hL .* GHK.(V_pn, sol.Ca_i)
    IK_ir   = pn.g_K_ir .* sol.mir          .* (V_pn .- pn.E_K)
    IK_M_pn = pn.g_K_M  .* sol.mM           .* (V_pn .- pn.E_K)
    ILeak_pn = pn.g_Leak                    .* (V_pn .- pn.E_Leak)

    current = Current(INaV1p3, INaV1p7, INaV1p8, IK_dr, IK_M, IK_AHP, ILeak, Iext, 
                        ICa_L, IK_ir, IK_M_pn, ILeak_pn, Inoci,
                               sol.Inoise, dV_dt)
    return current
end


