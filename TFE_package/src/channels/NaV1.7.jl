
# --------------------------- Na_V 1.7 --------------------------- #

function alpha_m_1_7(V; lido_shift=0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp+lido_shift))/-15.43))
end

function alpha_h_1_7(V; lido_shift=0)
    jp = 4.2
    return 0.0744/(1+exp((V-(-99.76-jp+lido_shift))/11.07))
end

function beta_m_1_7(V; lido_shift=0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp+lido_shift))/14.53))
end

function beta_h_1_7(V; lido_shift=0)
    jp = 4.2
    return 2.54/(1+exp((V-(-7.8-jp+lido_shift))/-10.68))
end

# ---- #

function h_inf_1_7(V; with_original = true, C_lido=0)
    if !with_original
        return control_1_7_inactivation(V; C_lido=C_lido)
    end
    # Lidocaine effect
    lido_shift = inact_1_7_shift(C_lido)
    return alpha_h_1_7(V; lido_shift=lido_shift) / (alpha_h_1_7(V; lido_shift=lido_shift) + beta_h_1_7(V; lido_shift=lido_shift))
end

function tau_h_1_7(V; with_original = true, C_lido=0)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h_1_7(V; lido_shift=lido_shift) + beta_h_1_7(V; lido_shift=lido_shift))
end

function m_inf_1_7(V; with_original = true, C_lido=0)
    if !with_original
        return control_1_7_activation(V; C_lido=C_lido)
    end
    # Lidocaine effect
    lido_shift = act_1_7_shift(C_lido)
    return alpha_m_1_7(V; lido_shift=lido_shift) / (alpha_m_1_7(V; lido_shift=lido_shift) + beta_m_1_7(V; lido_shift=lido_shift))
end

function tau_m_1_7(V; with_original = true, C_lido=0)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_m_1_7(V; lido_shift=lido_shift) + beta_m_1_7(V; lido_shift=lido_shift))
end

# ---- #
# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine

function control_1_7_activation(V; C_lido=0) 
    # With 100 µM lidocaine 
    # Boltzmann(V, 1.0, -23.92, -3.89, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -25.56, -3.75, 0.0, 0.0, 1.0)
end

function control_1_7_inactivation(V; C_lido=0)
    # With 100 µM lidocaine 
    # Boltzmann(V, 1.0, -79.02, 5.52, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -68.38, 4.37, 0.0, 0.0, 1.0)
end