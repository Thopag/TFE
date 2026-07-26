
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

# ----------------------------------------- #

struct DICResults
    V::Vector{Float64}
    VEC_g_f::Vector{Vector{Float64}}
    VEC_g_s::Vector{Vector{Float64}}
    VEC_g_us::Vector{Vector{Float64}}
end

function DIC_result(V, VEC_p_model)

    L = length(VEC_p_model)
    VEC_g_f  = Vector{Vector{Float64}}(undef, L)
    VEC_g_s  = Vector{Vector{Float64}}(undef, L)
    VEC_g_us = Vector{Vector{Float64}}(undef, L)
    return DICResults(V, VEC_g_f, VEC_g_s, VEC_g_us)
end

function make_DIC(V, p)

    g_f = zeros(eltype(V), size(V))
    g_s = zeros(eltype(V), size(V))
    g_us = zeros(eltype(V), size(V))

    n = p.nociceptor
    lido = p.lidocaine

    with_shift = lido.with_shift

    # ----------- #

    h_1p3(V) = h3_inf(V; shift=lido.shift_h3, with_shift=with_shift)
    m_1p3(V) = m3_inf(V)

    h_1p7(V) = h7_inf(V; shift=lido.shift_h7, with_shift=with_shift)
    m_1p7(V) = m7_inf(V)

    h_1p8(V) = h8_inf(V; shift=lido.shift_h8, with_shift=with_shift)
    m_1p8(V) = m8_inf(V; shift=lido.shift_m8, with_shift=with_shift)

    l_inf_K_dr = ldr_inf
    n_inf_K_dr = ndr_inf

    n_inf_K_M = nM_inf

    z_K_AHP_inf = zAHP_inf

    vec_xi_inf = [h_1p3, m_1p3,
                h_1p7, m_1p7,
                h_1p8, m_1p8,
                l_inf_K_dr, n_inf_K_dr,
                n_inf_K_M,
                z_K_AHP_inf]

    # ----------- #

    dV_dot_h_1_3(V) = - (n.g_NaV1p3 * (m_1p3(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_3(V) = - (n.g_NaV1p3 * 3 * (m_1p3(V)^2) * h_1p3(V) * (V - n.E_Na)) / n.C

    dV_dot_h_1_7(V) = - (n.g_NaV1p7 * (m_1p7(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_7(V) = - (n.g_NaV1p7 * 3 * (m_1p7(V)^2) * h_1p7(V) * (V - n.E_Na)) / n.C

    dV_dot_h_1_8(V) = - (n.g_NaV1p8 * (m_1p8(V)^3) * (V - n.E_Na)) / n.C
    dV_dot_m_1_8(V) = - (n.g_NaV1p8 * 3 * (m_1p8(V)^2) * h_1p8(V) * (V - n.E_Na)) / n.C

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

    # ----------- #

    vec_tau = [tau_h3, tau_m3,
                tau_h7, tau_m7,
                tau_h8, tau_m8,
                tau_ldr, tau_ndr,
                tau_nM,
                tau_zAHP]


    # ----------- #

    for (tau, dV_dot_dxi, xi_inf) in zip(vec_tau, vec_dV_dot_dxi, vec_xi_inf)
        w_fs, w_su = get_weights(V, tau)

        # Make derivative
        dxi_inf_dV(x) = ForwardDiff.derivative(a -> xi_inf(a), x)
        r = dV_dot_dxi.(V) .* dxi_inf_dV.(V)

        g_f  =  g_f   .+ w_fs .* r
        g_s  =  g_s   .+ (w_su .- w_fs) .* r
        g_us =  g_us  .+ (1 .- w_su) .* r

    end

    return g_f, g_s, g_us
end

function fill_DIC_result(i::Int, results::DICResults, VEC_p_model)

    p_model = VEC_p_model[i]
    g_f, g_s, g_us = make_DIC(results.V, p_model)

    results.VEC_g_f[i] = g_f
    results.VEC_g_s[i] = g_s
    results.VEC_g_us[i] = g_us
    return
end

function DIC_analyses(V, fp::FileParameters)

    VEC_p_model = fp.VEC_p_model
    results = DIC_result(V, VEC_p_model)
    for i in 1:length(VEC_p_model)
        fill_DIC_result(i, results, VEC_p_model)
    end
    return results
end
