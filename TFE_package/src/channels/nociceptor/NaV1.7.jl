
# --------------------------- NaV1.7 --------------------------- #

function alpha_m7(V; lido_shift=0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp+lido_shift))/-15.43))
end

function alpha_h7(V; lido_shift=0)
    jp = 4.2
    return 0.0744/(1+exp((V-(-99.76-jp+lido_shift))/11.07))
end

function beta_m7(V; lido_shift=0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp+lido_shift))/14.53))
end

function beta_h7(V; lido_shift=0)
    jp = 4.2
    return 2.54/(1+exp((V-(-7.8-jp+lido_shift))/-10.68))
end

# ---- #

function h7_inf(V; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    # Lidocaine effect
    lido_shift = h7_shift(C_lido, shift, with_shift, linear_shift_mode)
    return alpha_h7(V; lido_shift=lido_shift) / (alpha_h7(V; lido_shift=lido_shift) + beta_h7(V; lido_shift=lido_shift))
end

function tau_h7(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h7(V; lido_shift=lido_shift) + beta_h7(V; lido_shift=lido_shift))
end

function m7_inf(V; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    # Lidocaine effect
    lido_shift = m7_shift()
    return alpha_m7(V; lido_shift=lido_shift) / (alpha_m7(V; lido_shift=lido_shift) + beta_m7(V; lido_shift=lido_shift))
end

function tau_m7(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_m7(V; lido_shift=lido_shift) + beta_m7(V; lido_shift=lido_shift))
end

# ---- #

function dot_m7(V, m7; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    x_inf = m7_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_m7(V)
    return (x_inf-m7)/tau_x
end

function dot_h7(V, h7; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    x_inf = h7_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_h7(V)
    return (x_inf-h7)/tau_x
end

# ---- #
# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine
# Other gate function that was tested should be removed in the final code

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