
# --------------------------- NaV1.3 --------------------------- #

function alpha_m3(V; lido_shift::Float64=0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp-12+lido_shift))/-15.43))
end

function alpha_h3(V; lido_shift::Float64=0)
    jp = 4.2
    return 0.0744/(1+exp((V-(-99.76-jp+10+lido_shift))/11.07))
end

function beta_m3(V; lido_shift::Float64=0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp-12+lido_shift))/14.53))
end

function beta_h3(V; lido_shift::Float64=0)
    jp = 4.2
    return 2.54/(1+exp((V-(-7.8-jp+10+lido_shift))/-10.68))
end

# ---- #

function h3_inf(V; C_lido::Float64=0.0, shift::Float64=0.0, with_shift::Bool=false, linear_shift_mode::Bool=false)
    # Lidocaine effect
    lido_shift = h3_shift(C_lido, shift, with_shift, linear_shift_mode)
    return alpha_h3(V;lido_shift=lido_shift) / (alpha_h3(V;lido_shift=lido_shift) + beta_h3(V;lido_shift=lido_shift))
end

function tau_h3(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h3(V; lido_shift=lido_shift) + beta_h3(V; lido_shift=lido_shift))
end

function m3_inf(V; C_lido::Float64=0.0, shift::Float64=0.0, with_shift::Bool=false, linear_shift_mode::Bool=false)
    # Lidocaine effect
    lido_shift = m3_shift()
    return alpha_m3(V; lido_shift=lido_shift) / (alpha_m3(V; lido_shift=lido_shift) + beta_m3(V; lido_shift=lido_shift))
end

function tau_m3(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_m3(V; lido_shift=lido_shift) + beta_m3(V; lido_shift=lido_shift))
end

# ---- #

function dot_m3(V, m3; C_lido::Float64=0.0, shift::Float64=0.0, with_shift::Bool=false, linear_shift_mode::Bool=false)
    x_inf = m3_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_m3(V)
    return (x_inf-m3)/tau_x
end

function dot_h3(V, h3; C_lido::Float64=0.0, shift::Float64=0.0, with_shift::Bool=false, linear_shift_mode::Bool=false)
    x_inf = h3_inf(V; C_lido=C_lido, shift=shift, with_shift=with_shift, linear_shift_mode=linear_shift_mode)
    tau_x = tau_h3(V)
    return (x_inf-h3)/tau_x
end