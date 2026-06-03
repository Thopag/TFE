export DIC, init_DIC, iteration_DIC

function tau_f(V)
    return tau_m7(V)
end

function tau_s(V)
    return tau_ndr(V)
end

function tau_us(V)
    return tau_ldr(V)
end

function get_weights(V, tau_xi)
    w_fs = zeros(eltype(V), size(V))
    w_su = zeros(eltype(V), size(V))

    for (i, (xi, f, s, us)) in enumerate(zip(tau_xi.(V), tau_f.(V), tau_s.(V), tau_us.(V)))
        if xi <= f
            w_fs[i] = 1.0
            w_su[i] = 1.0
        elseif f < xi <= s
            w_fs[i] = ( log10(s)-log10(xi) )/( log10(s)-log10(f) )
            w_su[i] = 1.0
        elseif s < xi <= us
            w_fs[i] = 0.0
            w_su[i] = ( log10(us)-log10(xi) )/( log10(us)-log10(s) )
        elseif us < xi
            w_fs[i] = 0.0
            w_su[i] = 0.0
        end
    end
    return w_fs, w_su
end

function DIC(V, p; with_plot=false)

    g_f = zeros(eltype(V), size(V))
    g_s = zeros(eltype(V), size(V))
    g_us = zeros(eltype(V), size(V))

    n = p.nociceptor
    lido = p.lidocaine

    linear_shift_mode = lido.linear_shift_mode
    with_shift = lido.with_shift
    C_lido = lido.concentration

    h_inf_1p3(V) = h3_inf(V; C_lido=C_lido, shift=lido.shift_h3, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    m_inf_1p3(V) = m3_inf(V)

    h_inf_1p7(V) = h7_inf(V; C_lido=C_lido, shift=lido.shift_h7, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    m_inf_1p7(V) = m7_inf(V)

    h_inf_1p8(V) = h8_inf(V; C_lido=C_lido, shift=lido.shift_h8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    m_inf_1p8(V) = m8_inf(V; C_lido=C_lido, shift=lido.shift_m8, with_shift=with_shift, linear_shift_mode=linear_shift_mode)

    l_inf_K_dr = ldr_inf
    n_inf_K_dr = ndr_inf

    n_inf_K_M = nM_inf

    z_K_AHP_inf = zAHP_inf

    vec_xi_inf = [h_inf_1p3, m_inf_1p3,
                h_inf_1p7, m_inf_1p7,
                h_inf_1p8, m_inf_1p8,
                l_inf_K_dr, n_inf_K_dr,
                n_inf_K_M,
                z_K_AHP_inf]

    dV_dot_h_1_3(V) = - (n.g_NaV1p3 * (m_inf_1p3(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_3(V) = - (n.g_NaV1p3 * 3 * (m_inf_1p3(V)^2) * h_inf_1p3(V) * (V - n.E_Na)) / n.C

    dV_dot_h_1_7(V) = - (n.g_NaV1p7 * (m_inf_1p7(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_7(V) = - (n.g_NaV1p7 * 3 * (m_inf_1p7(V)^2) * h_inf_1p7(V) * (V - n.E_Na)) / n.C

    dV_dot_h_1_8(V) = - (n.g_NaV1p8 * (m_inf_1p8(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_8(V) = - (n.g_NaV1p8 * 3 * (m_inf_1p8(V)^2) * h_inf_1p8(V) * (V - n.E_Na)) / n.C

    dV_dot_l_K_dr(V) = - (n.g_K_dr * (n_inf_K_dr(V)^3) * (V - n.E_K)) / n.C
    dV_dot_n_K_dr(V) = - (n.g_K_dr * 3 * (n_inf_K_dr(V)^2) * l_inf_K_dr(V) * (V - n.E_K)) / n.C

    dV_dot_n_K_M(V) = - (n.g_K_M * (V - n.E_K)) / n.C

    dV_dot_zAHP(V) = - (n.g_K_AHP * (V - n.E_K)) / n.C

    vec_dV_dot_dxi = [dV_dot_h_1_3, dV_dot_m_1_3,
                dV_dot_h_1_7, dV_dot_m_1_7,
                dV_dot_h_1_8, dV_dot_m_1_8,
                dV_dot_l_K_dr, dV_dot_n_K_dr,
                dV_dot_n_K_M,
                dV_dot_zAHP]

    vec_tau = [tau_h3, tau_m3,
                tau_h7, tau_m7,
                tau_h8, tau_m8,
                tau_ldr, tau_ndr,
                tau_nM,
                tau_zAHP]

    labels = ["h3", "m3",
                "h7", "m7",
                "h8", "m8",
                "ldr", "ndr",
                "nM",
                "zAHP"]
    colors = [:blue, :blue,
                :red, :red,
                :green, :green,
                :orange, :orange,
                :purple,
                :brown]
    style = [:dash, :solid,
                :dash, :solid,
                :dash, :solid,
                :dash, :solid,
                :solid,
                :solid]

    if with_plot
        alpha = 0.6
        xticks = [-120, -90, -60, -30, 0, 30, 60]

        plt_f =         plot(xlabel="Voltage (mV)", ylabel=L"g fast"  , xticks = xticks)
        plt_s =         plot(xlabel="Voltage (mV)", ylabel=L"g slow", xticks = xticks)
        plt_us =        plot(xlabel="Voltage (mV)", ylabel=L"g ultra slow", xticks = xticks)
        plt_derivs =    plot(xlabel="Voltage (mV)", ylabel=L"Steady states Derivatives", xticks = xticks)
        plt_ss =        plot(xlabel="Voltage (mV)", ylabel=L"Steady states", xticks = xticks, legend=:bottomright)
    end

    for (tau, dV_dot_dxi, xi_inf, label, c, s) in zip(vec_tau, vec_dV_dot_dxi, vec_xi_inf, labels, colors, style)
        w_fs, w_su = get_weights(V, tau)

        # Make derivative
        dxi_inf_dV(x) = ForwardDiff.derivative(a -> xi_inf(a), x)
        r = dV_dot_dxi.(V) .* dxi_inf_dV.(V)

        g_f = g_f   .+ w_fs .* r
        g_s = g_s   .+ (w_su .- w_fs) .* r
        g_us = g_us .+ (1 .- w_su) .* r

        if with_plot
            # plot steady states
            plot!(plt_ss, V, xi_inf.(V), label=label, color=c, linestyle=s)

            # check derivative
            plot!(plt_derivs, V, dxi_inf_dV.(V), label=label, color=c, linestyle=s)

            plot!(plt_f , V, w_fs .* r           , label=label, color=c, linestyle=s, alpha=alpha)
            plot!(plt_s , V, (w_su .- w_fs) .* r , label=label, color=c, linestyle=s, alpha=alpha)
            plot!(plt_us, V, (1 .- w_su) .* r   , label=label, color=c, linestyle=s, alpha=alpha)
        end
    end

    if with_plot
        plot!(plt_f, V, g_f, color=:black, label="g_f", alpha=0.8)
        plot!(plt_s, V, g_s, color=:black, label="g_s", alpha=0.8)
        plot!(plt_us, V, g_us, color=:black, label="g_us", alpha=0.8)

        savefig(plt_f, "plots/DIC/g_f.pdf")
        savefig(plt_s, "plots/DIC/g_s.pdf")
        savefig(plt_us, "plots/DIC/g_us.pdf")
        savefig(plt_derivs, "plots/DIC/derivs.pdf")
        savefig(plt_ss, "plots/DIC/steady_states.pdf")
    end

    return g_f, g_s, g_us
end

# ----------------------------------------------- #

function init_DIC(L)
    xticks = [-120, -90, -60, -30, 0, 30, 60]

    if L == 1
        rainbow = [:black]
    else
        rainbow = [get(colorschemes[:rainbow], i) for i in range(0.0, stop=1.0, length=L)]
    end

    plt_f = plot(xlabel="Voltage (mV)", ylabel="g fast", xticks = xticks)
    plt_s = plot(xlabel="Voltage (mV)", ylabel="g slow", xticks = xticks)
    plt_us = plot(xlabel="Voltage (mV)", ylabel="g ultra slow", xticks = xticks)
    return plt_f, plt_s, plt_us, rainbow
end

function iteration_DIC(V, p_model, i, inter_label, plt_f, plt_s, plt_us, colors; with_extra_plot=true)
    g_f, g_s, g_us = DIC(V, p_model; with_plot=with_extra_plot)
    plot!(plt_f, V, g_f, label=inter_label, color=colors[i])
    plot!(plt_s, V, g_s, label=inter_label, color=colors[i])
    plot!(plt_us, V, g_us, label=inter_label, color=colors[i])
end