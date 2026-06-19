export steady_state_currents, init_ss_currents, iteration_ss_currents

function steady_state_currents(p, V)

    n = p.nociceptor
    stim = p.stimulation
    lido = p.lidocaine

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

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

    m3 = m3_inf.(V)
    h3 = h3_inf.(V; C_lido=C_lido, shift=lido.shift_h3, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    m7 = m7_inf.(V)
    h7 = h7_inf.(V; C_lido=C_lido, shift=lido.shift_h7, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    m8 = m8_inf.(V; C_lido=C_lido, shift=lido.shift_m8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    h8 = h8_inf.(V; C_lido=C_lido, shift=lido.shift_h8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    nM = nM_inf.(V)

    ndr = ndr_inf.(V)
    ldr = ldr_inf.(V)

    zAHP = zAHP_inf.(V)

    INaV1p3 = g_NaV1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_NaV1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_NaV1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IK_dr = g_K_dr .* (ndr.^3) .* ldr .* (V .- E_K)
    IK_M = g_K_M .* nM .* (V .- E_K)
    IK_AHP = g_K_AHP .* (zAHP.^1) .* (V .- E_K)
    ILeak = g_Leak .* (V .- E_Leak)

    Excitation = ((stim.amp * (10^-6)) / (n.CellArea * (10^-8))) 
    I0         = ((stim.Ihold * (10^-6)) / (n.CellArea * (10^-8))) 
    Iext = I0 + Excitation

    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IK_dr .- IK_M .- ILeak .- IK_AHP) ./ n.C

    return INaV1p3, INaV1p7, INaV1p8, IK_dr, IK_M, IK_AHP, ILeak, Iext, dV_dt
end

function init_ss_currents(V, p_default_model)
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    ylimits =  :native #(-0.30, 0.005)

    plt = plot(xlabel=L"Voltage ($mV$)", ylabel= L"Steady State Current ($\mu A/cm^2$)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks)
    plot!(ylims=ylimits)

    INaV1p3, INaV1p7, INaV1p8, IK_dr, IK_M, IK_AHP, ILeak, Iext, dV_dt = steady_state_currents(p_default_model, V)
    plot!(plt, V, .- IK_dr, label=L"- K_{dr}", color=:orange, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IK_M, label=L"- K_{M}", color=:purple, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IK_AHP, label=L"- K_{AHP}", color=:brown, alpha=1, linewidth = 1.5)

    # plot!(plt, V, INaV1p3, label=L"NaV1.3", color=:blue, alpha=1)
    # plot!(plt, V, INaV1p7, label=L"NaV1.7", color=:red, alpha=1)
    # plot!(plt, V, INaV1p8, label=L"NaV1.8", color=:green, alpha=1)
    return plt
end

function iteration_ss_currents(plt, p_model, V, i, inter_label, reds, blues, greens, greys)
    INaV1p3, INaV1p7, INaV1p8, IK_dr, IK_M, IK_AHP, ILeak, Iext, dV_dt = steady_state_currents(p_model, V)

    plot!(plt, [], [], label=inter_label, color=greys[i])
    plot!(plt, V, INaV1p3, label="", color=blues[i])
    plot!(plt, V, INaV1p7, label="", color=reds[i])
    plot!(plt, V, INaV1p8, label="", color=greens[i])
end