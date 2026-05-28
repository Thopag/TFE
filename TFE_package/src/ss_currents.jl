export steady_state_currents, init_ss_currents, iteration_ss_currents

function steady_state_currents(p, V)

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

    C_lido = p.C_lidocaine

    m3 = m_inf_1_3.(V; C_lido=C_lido)
    h3 = h_inf_1_3.(V; C_lido=C_lido)

    m7 = m_inf_1_7.(V; C_lido=C_lido)
    h7 = h_inf_1_7.(V; C_lido=C_lido)

    m8 = m_inf_1_8.(V; C_lido=C_lido)
    h8 = h_inf_1_8.(V; C_lido=C_lido)

    nm = n_inf_K_M.(V)

    ndr = n_inf_K_dr.(V)
    ldr = l_inf_K_dr.(V)

    z_AHP = z_AHP_inf.(V)

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)
    Iext = p.I0 .+ p.Excitation

    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IKdr .- IKm .- ILeak .- IAHP) ./ p.C

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt
end

function init_ss_currents(V, get_param)
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    ylimits =  :native #(-0.30, 0.005)

    plt = plot(xlabel=L"Voltage ($mV$)", ylabel= L"Steady State Current ($\mu A/cm^2$)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks)
    plot!(ylims=ylimits)

    default_p = get_param(0.0)
    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = steady_state_currents(default_p, V)
    plot!(plt, V, .- IKdr, label=L"- K_{dr}", color=:orange, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IKm, label=L"- K_{M}", color=:purple, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IAHP, label=L"- K_{AHP}", color=:brown, alpha=1, linewidth = 1.5)

    # plot!(plt, V, INaV1p3, label=L"NaV1.3", color=:blue, alpha=1)
    # plot!(plt, V, INaV1p7, label=L"NaV1.7", color=:red, alpha=1)
    # plot!(plt, V, INaV1p8, label=L"NaV1.8", color=:green, alpha=1)
    return plt
end

function iteration_ss_currents(plt, p, V, i, inter_label, reds, blues, greens, greys)
    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = steady_state_currents(p, V)
        
    plot!(plt, [], [], label=inter_label, color=greys[i])
    plot!(plt, V, INaV1p3, label="", color=blues[i])
    plot!(plt, V, INaV1p7, label="", color=reds[i])
    plot!(plt, V, INaV1p8, label="", color=greens[i])
end