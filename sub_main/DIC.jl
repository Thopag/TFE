

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

function main()
    V = -100.0:0.5:50.0

    g_f = zeros(eltype(V), size(V))
    g_s = zeros(eltype(V), size(V))
    g_us = zeros(eltype(V), size(V))

    vec_dV_dot_dxi = [ODE.h_inf_1_3, ODE.m_inf_1_3,
                ODE.h_inf_1_7, ODE.m_inf_1_7,
                ODE.h_inf_1_8, ODE.m_inf_1_8,
                ODE.l_inf_K_dr, ODE.n_inf_K_dr,
                ODE.n_inf_K_M,
                ODE.z_AHP_inf] # change

    vec_xi_inf = [ODE.h_inf_1_3, ODE.m_inf_1_3,
                ODE.h_inf_1_7, ODE.m_inf_1_7,
                ODE.h_inf_1_8, ODE.m_inf_1_8,
                ODE.l_inf_K_dr, ODE.n_inf_K_dr,
                ODE.n_inf_K_M,
                ODE.z_AHP_inf]

    vec_tau = [ODE.tau_h_1_3, ODE.tau_m_1_3,
                ODE.tau_h_1_7, ODE.tau_m_1_7,
                ODE.tau_h_1_8, ODE.tau_m_1_8,
                ODE.tau_l_K_dr, ODE.tau_n_K_dr,
                ODE.tau_n_K_M,
                ODE.tau_z_AHP]

    for (tau, dV_dot_dxi, xi_inf) in zip(vec_tau, vec_dV_dot_dxi, vec_xi_inf)
        w_fs, w_su = get_weights(V, tau)

        dxi_inf_dV(x) = ForwardDiff.derivative(a -> xi_inf(a), x)

        # plt = plot(V, dxi_inf_dV.(V), label="", title="deriv")
        # display(plt)
        # r = dV_dot_dxi.(V) .* dxi_inf_dV.(V)

        # g_f = g_f   .+ w_fs .* r
        # g_s = g_s   .+ (w_su .- w_fs) .* r
        # g_us = g_us .+ (1 .- w_su) .* r
    end

    # plt_f = plot(V, g_f, label="", title="g_f")
    # plt_s = plot(V, g_s, label="", title="g_s")
    # plt_us = plot(V, g_us, label="", title="g_us")

    # savefig(plt_f, "plots/g_f.svg")
    # savefig(plt_s, "plots/g_s.svg")
    # savefig(plt_us, "plots/g_us.svg")
end

main()