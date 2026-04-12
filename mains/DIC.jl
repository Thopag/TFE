using ForwardDiff

function tau_f(V)
    return ODE.tau_m_1_7(V)
end

function tau_s(V)
    return ODE.tau_n_K_dr(V)
end

function tau_us(V)
    return ODE.tau_l_K_dr(V)
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

function DIC(V, p; shift=0.0, with_plot=false)

    g_f = zeros(eltype(V), size(V))
    g_s = zeros(eltype(V), size(V))
    g_us = zeros(eltype(V), size(V))

    h_inf_1p3(V) = ODE.h_inf_1_3(V; C_lido=shift, with_lido_shift=true)
    m_inf_1p3(V) = ODE.m_inf_1_3(V; C_lido=shift, with_lido_shift=true)

    h_inf_1p7(V) = ODE.h_inf_1_7(V; C_lido=shift, with_lido_shift=true)
    m_inf_1p7(V) = ODE.m_inf_1_7(V; C_lido=shift, with_lido_shift=true)

    h_inf_1p8(V) = ODE.h_inf_1_8(V; C_lido=shift, with_lido_shift=true)
    m_inf_1p8(V) = ODE.m_inf_1_8(V; C_lido=shift, with_lido_shift=true)

    l_inf_Kdr = ODE.l_inf_K_dr
    n_inf_Kdr = ODE.n_inf_K_dr

    n_inf_KM = ODE.n_inf_K_M

    z_K_AHP_inf = ODE.z_AHP_inf

    vec_xi_inf = [h_inf_1p3, m_inf_1p3,
                h_inf_1p7, m_inf_1p7,
                h_inf_1p8, m_inf_1p8,
                l_inf_Kdr, n_inf_Kdr,
                n_inf_KM,
                z_K_AHP_inf]

    dV_dot_h_1_3(V) = - (p.g_nav1p3 * (m_inf_1p3(V)^3) * (V - p.E_Na)) / p.C
    dV_dot_m_1_3(V) = - (p.g_nav1p3 * 3 * (m_inf_1p3(V)^2) * h_inf_1p3(V) * (V - p.E_Na)) / p.C

    dV_dot_h_1_7(V) = - (p.g_nav1p7 * (m_inf_1p7(V)^3) * (V - p.E_Na)) / p.C
    dV_dot_m_1_7(V) = - (p.g_nav1p7 * 3 * (m_inf_1p7(V)^2) * h_inf_1p7(V) * (V - p.E_Na)) / p.C

    dV_dot_h_1_8(V) = - (p.g_nav1p8 * (m_inf_1p8(V)^3) * (V - p.E_Na)) / p.C
    dV_dot_m_1_8(V) = - (p.g_nav1p8 * 3 * (m_inf_1p8(V)^2) * h_inf_1p8(V) * (V - p.E_Na)) / p.C

    dV_dot_l_K_dr(V) = - (p.g_Kdr * (n_inf_Kdr(V)^3) * (V - p.E_k)) / p.C
    dV_dot_n_K_dr(V) = - (p.g_Kdr * 3 * (n_inf_Kdr(V)^2) * l_inf_Kdr(V) * (V - p.E_k)) / p.C

    dV_dot_n_K_M(V) = - (p.g_Km * (V - p.E_k)) / p.C

    dV_dot_z_AHP(V) = - (p.g_AHP * (V - p.E_k)) / p.C

    vec_dV_dot_dxi = [dV_dot_h_1_3, dV_dot_m_1_3,
                dV_dot_h_1_7, dV_dot_m_1_7,
                dV_dot_h_1_8, dV_dot_m_1_8,
                dV_dot_l_K_dr, dV_dot_n_K_dr,
                dV_dot_n_K_M,
                dV_dot_z_AHP]

    vec_tau = [ODE.tau_h_1_3, ODE.tau_m_1_3,
                ODE.tau_h_1_7, ODE.tau_m_1_7,
                ODE.tau_h_1_8, ODE.tau_m_1_8,
                ODE.tau_l_K_dr, ODE.tau_n_K_dr,
                ODE.tau_n_K_M,
                ODE.tau_z_AHP]

    labels = ["h 1.3", "m 1.3",
                "h 1.7", "m 1.7",
                "h 1.8", "m 1.8",
                "l Kdr", "n Kdr",
                "n KM",
                "z AHP"]
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
        plt_f = plot(xlabel="Voltage (mV)", title="g_f")
        plt_s = plot(xlabel="Voltage (mV)", title="g_s")
        plt_us = plot(xlabel="Voltage (mV)", title="g_us")
        plt_derivs = plot(xlabel="Voltage (mV)", title="Steady states Derivatives")
        plt_ss = plot(xlabel="Voltage (mV)", title="Steady states", legend=:bottomright)
        alpha = 0.6
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
        plot!(plt_f, V, g_f, color=:black, label="g_f", alpha=0.7)
        plot!(plt_s, V, g_s, color=:black, label="g_s", alpha=0.7)
        plot!(plt_us, V, g_us, color=:black, label="g_us", alpha=0.7)

        savefig(plt_f, "plots/g_f.svg")
        savefig(plt_s, "plots/g_s.svg")
        savefig(plt_us, "plots/g_us.svg")
        savefig(plt_derivs, "plots/derivs.svg")
        savefig(plt_ss, "plots/steady_states.svg")
    end

    return g_f, g_s, g_us
end

function main()
    V = -100.0:0.5:50.0

    titre = "1.8 | 60 % act | 40 % inact |"

    get_param = DIV0_parameter
    amp = 100
    stim_on = 500.0
    stim_length = 1000.0
    p  = get_param(amp, stim_on, stim_length;)

    plt_f = plot(xlabel="Voltage (mV)", title="$title g_f")
    plt_s = plot(xlabel="Voltage (mV)", title="$title g_s")
    plt_us = plot(xlabel="Voltage (mV)", title="$title g_us")

    shifts = 0.0:2:14.0
    shifts = [0.0]
    for shift in shifts
        g_f, g_s, g_us = DIC(V, p; shift=shift, with_plot=true)
        plot!(plt_f, V, g_f, label="$shift", alpha=1)
        plot!(plt_s, V, g_s, label="$shift", alpha=1)
        plot!(plt_us, V, g_us, label="$shift", alpha=1)
    end
    savefig(plt_f, "plots/all_g_f.svg")
    savefig(plt_s, "plots/all_g_s.svg")
    savefig(plt_us, "plots/all_g_us.svg")
end

main()