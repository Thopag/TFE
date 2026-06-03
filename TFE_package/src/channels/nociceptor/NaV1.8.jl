
# --------------------------- NaV1.8 --------------------------- #

function alpha_m8(V; lido_shift=0)
    jp = 5.3
    return 7.21/(1+exp((V-(0.063-jp+lido_shift))/-7.86))
    #human version
    #return 7.35-7.35/(1+exp((V-(-1.38-jp+lido_shift))/10.9))
end

function alpha_h8(V; lido_shift=0)
    jp = 5.3
    return 1.63/(1+exp((V-(-68.5-jp+lido_shift))/10.01))
    #human version
    #return 0.011+1.39/(1+exp((V-(-78.04-jp+lido_shift))/11.32))
end

function beta_m8(V; lido_shift=0)
    jp = 5.3
    return 7.4/(1+exp((V-(-53.06-jp+lido_shift))/19.34))
    #human version
    #return 5.97/(1+exp((V-(-56.43-jp+lido_shift))/18.26))
end

function beta_h8(V; lido_shift=0)
    jp = 5.3
    return 0.81/(1+exp((V-(11.44-jp+lido_shift))/-13.12))
    #human version
    #return 0.56-0.56/(1+exp((V-(21.82-jp+lido_shift))/20.03))
end

# ---- #

function h8_inf(V; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    # Lidocaine effect
    lido_shift = h8_shift(C_lido, shift, with_shift, linear_shift_mode)
    return alpha_h8(V; lido_shift=lido_shift) / (alpha_h8(V; lido_shift=lido_shift) + beta_h8(V; lido_shift=lido_shift))
end

function tau_h8(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h8(V; lido_shift=lido_shift) + beta_h8(V; lido_shift=lido_shift))
end

function m8_inf(V; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    # Lidocaine effect
    lido_shift = m8_shift(C_lido, shift, with_shift, linear_shift_mode)
    return alpha_m8(V; lido_shift=lido_shift) / (alpha_m8(V; lido_shift=lido_shift) + beta_m8(V; lido_shift=lido_shift))
end

function tau_m8(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_m8(V; lido_shift=lido_shift) + beta_m8(V; lido_shift=lido_shift))
end

# ---- #

function dot_m8(V, m8; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    x_inf = m8_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_m8(V)
    return (x_inf-m8)/tau_x
end

function dot_h8(V, h8; C_lido=0.0, shift=0.0, with_shift=false, linear_shift_mode=false)
    x_inf = h8_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_h8(V)
    return (x_inf-h8)/tau_x
end

# ---- #
# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine
# Other gate function that was tested should be removed in the final code

function control_1_8_activation(V; C_lido=0)
    # With 100 µM lidocaine
    # Boltzmann(V, 1.0, 12.32, -6.63, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, 6.24, -5.73, 0.0, 0.0, 1.0)
end

function control_1_8_inactivation(V; C_lido=0)
    # With 100 µM lidocaine
    # Boltzmann(V, 1.0, -46.81, 8.07, 0.0, 0.0, 1.0)
    return Boltzmann(V, 1.0, -42.72, 9.05, 0.0, 0.0, 1.0)
end