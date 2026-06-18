export retrieve_nociceptor_currents, nociceptor_SS_currents

function INaV1p3(V, m3, h3, g_NaV1p3, E_Na)
    I = g_NaV1p3  * (m3^3) * h3   * (V-E_Na)
    return I
end
function INaV1p7(V, m7, h7, g_NaV1p7, E_Na)
    I = g_NaV1p7  * (m7^3) * h7   * (V-E_Na)
    return I
end
function INaV1p8(V, m8, h8, g_NaV1p8, E_Na)
    I = g_NaV1p8  * (m8^3) * h8   * (V-E_Na)
    return I
end
function IK_dr(V, ndr, ldr, g_K_dr, E_K)
    I = g_K_dr  * (ndr^3) * ldr * (V-E_K)
    return I
end
function IK_M(V, nM, g_K_M, E_K)
    I = g_K_M * nM  * (V-E_K)
    return I
end
function IK_AHP(V, zAHP, g_K_AHP, E_K)
    I = g_K_AHP * (zAHP^1) * (V-E_K)
    return I
end
function ILeak(V, g_Leak, E_Leak)
    I = g_Leak * (V-E_Leak)
    return I
end

struct NociceptorCurrent{T}
    INaV1p3::T
    INaV1p7::T
    INaV1p8::T
    IK_dr::T
    IK_M::T
    IK_AHP::T
    ILeak::T
    Iext::T
end

function retrieve_nociceptor_currents(noci_sol, p_model)

    # ---- #
    n = p_model.nociceptor
    stim = p_model.stimulation
    V = noci_sol.V
    t = noci_sol.t

    Iext = stim.Ihold .+ (stim.is_activated.(t) .* stim.amp)  # [pA]
    Iext = Iext .* (10.0 .^(-6)) ./ (n.CellArea .* (10 .^(-8)))      # [µA/cm^2]

    nociceptor_current = NociceptorCurrent(INaV1p3.(V, noci_sol.m3, noci_sol.h3, n.g_NaV1p3, n.E_Na),
                                    INaV1p7.(V, noci_sol.m7, noci_sol.h7, n.g_NaV1p7, n.E_Na),
                                    INaV1p8.(V, noci_sol.m8, noci_sol.h8, n.g_NaV1p8, n.E_Na),
                                    IK_dr.(V, noci_sol.ndr, noci_sol.ldr, n.g_K_dr, n.E_K),
                                    IK_M.(V, noci_sol.nM, n.g_K_M, n.E_K),
                                    IK_AHP.(V, noci_sol.zAHP, n.g_K_AHP, n.E_K),
                                    ILeak.(V, n.g_Leak, n.E_Leak), Iext
                        )
    return nociceptor_current
end

function nociceptor_SS_currents(p_model, V)

    n = p_model.nociceptor
    lido = p_model.lidocaine

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

    nociceptor_current = NociceptorCurrent(INaV1p3.(V, m3, h3, n.g_NaV1p3, n.E_Na),
                                    INaV1p7.(V, m7, h7, n.g_NaV1p7, n.E_Na),
                                    INaV1p8.(V, m8, h8, n.g_NaV1p8, n.E_Na),
                                    IK_dr.(V, ndr, ldr, n.g_K_dr, n.E_K),
                                    IK_M.(V, nM, n.g_K_M, n.E_K),
                                    IK_AHP.(V, zAHP, n.g_K_AHP, n.E_K),
                                    ILeak.(V, n.g_Leak, n.E_Leak),
                                    V .* 0.0
                        )
    return nociceptor_current
end