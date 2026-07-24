
# --------------------------- NaV1.8 --------------------------- #

function alpha_m8(V; lido_shift::Float64=0)
    jp = 5.3
    return 7.21/(1+exp((V-(0.063-jp+lido_shift))/-7.86))
    #human version
    #return 7.35-7.35/(1+exp((V-(-1.38-jp+lido_shift))/10.9))
end

function alpha_h8(V; lido_shift::Float64=0)
    jp = 5.3
    return 1.63/(1+exp((V-(-68.5-jp+lido_shift))/10.01))
    #human version
    #return 0.011+1.39/(1+exp((V-(-78.04-jp+lido_shift))/11.32))
end

function beta_m8(V; lido_shift::Float64=0)
    jp = 5.3
    return 7.4/(1+exp((V-(-53.06-jp+lido_shift))/19.34))
    #human version
    #return 5.97/(1+exp((V-(-56.43-jp+lido_shift))/18.26))
end

function beta_h8(V; lido_shift::Float64=0)
    jp = 5.3
    return 0.81/(1+exp((V-(11.44-jp+lido_shift))/-13.12))
    #human version
    #return 0.56-0.56/(1+exp((V-(21.82-jp+lido_shift))/20.03))
end

# ---- #

function h8_inf(V; shift::Float64=0.0, with_shift::Bool=false)
    # Lidocaine effect
    lido_shift = h8_shift(shift, with_shift)
    return alpha_h8(V; lido_shift=lido_shift) / (alpha_h8(V; lido_shift=lido_shift) + beta_h8(V; lido_shift=lido_shift))
end

function tau_h8(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h8(V; lido_shift=lido_shift) + beta_h8(V; lido_shift=lido_shift))
end

function m8_inf(V; shift::Float64=0.0, with_shift::Bool=false)
    # Lidocaine effect
    lido_shift = m8_shift(shift, with_shift)
    return alpha_m8(V; lido_shift=lido_shift) / (alpha_m8(V; lido_shift=lido_shift) + beta_m8(V; lido_shift=lido_shift))
end

function tau_m8(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_m8(V; lido_shift=lido_shift) + beta_m8(V; lido_shift=lido_shift))
end

# ---- #

function dot_m8(V, m8; shift::Float64=0.0, with_shift::Bool=false)
    x_inf = m8_inf(V; shift=shift, with_shift=with_shift)
    tau_x = tau_m8(V)
    return (x_inf-m8)/tau_x
end

function dot_h8(V, h8; shift::Float64=0.0, with_shift::Bool=false)
    x_inf = h8_inf(V; shift=shift, with_shift=with_shift)
    tau_x = tau_h8(V)
    return (x_inf-h8)/tau_x
end
