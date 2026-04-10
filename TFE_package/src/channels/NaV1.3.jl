
# --------------------------- Na_V 1.3 --------------------------- #

function alpha_m_1_3(V; lido_shift=0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp-12+lido_shift))/-15.43))
end

function alpha_h_1_3(V; with_DIV0=true, lido_shift=0)
    jp = 4.2
    if with_DIV0
        return 0.0744/(1+exp((V-(-99.76-jp+lido_shift))/11.07))
    end
    return 0.0744/(1+exp((V-(-99.76-jp+10+lido_shift))/11.07))
end

function beta_m_1_3(V; lido_shift=0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp-12+lido_shift))/14.53))
end

function beta_h_1_3(V; with_DIV0=true, lido_shift=0)
    jp = 4.2
    if with_DIV0
        return 2.54/(1+exp((V-(-7.8-jp+lido_shift))/-10.68))
    end
    return 2.54/(1+exp((V-(-7.8-jp+10+lido_shift))/-10.68))
end

# ---- #

function h_inf_1_3(V; with_DIV0=false, with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0.0
    if with_lido_shift
        lido_shift = inact_1_3_shift(C_lido)
    end
    return alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) / (alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) + beta_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift))
end

function tau_h_1_3(V; with_DIV0=false, with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0.0
    if with_lido_shift
        lido_shift = 0.0
    end
    return 1 / (alpha_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift) + beta_h_1_3(V; with_DIV0=with_DIV0, lido_shift=lido_shift))
end

function m_inf_1_3(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0.0
    if with_lido_shift
        lido_shift = act_1_3_shift(C_lido)
    end
    return alpha_m_1_3(V; lido_shift=lido_shift) / (alpha_m_1_3(V; lido_shift=lido_shift) + beta_m_1_3(V; lido_shift=lido_shift))
end

function tau_m_1_3(V; with_original = true, C_lido=0, with_lido_shift=false)
    # Lidocaine effect
    lido_shift = 0.0
    if with_lido_shift
        lido_shift = 0.0
    end
    return 1 / (alpha_m_1_3(V; lido_shift=lido_shift) + beta_m_1_3(V; lido_shift=lido_shift))
end