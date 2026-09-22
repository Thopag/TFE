
# --------------------------- NaV1.7 --------------------------- #

function alpha_m7(V; lido_shift::Float64=0.0)
    jp = 4.2
    return 10.22/(1+exp((V-(-7.19-jp+lido_shift))/-15.43))
end

function alpha_h7(V; lido_shift::Float64=0.0)
    jp = 4.2
    return 0.0744/(1+exp((V-(-99.76-jp+lido_shift))/11.07))
end

function beta_m7(V; lido_shift::Float64=0.0)
    jp = 4.2
    return 23.76/(1+exp((V-(-70.37-jp+lido_shift))/14.53))
end

function beta_h7(V; lido_shift::Float64=0.0)
    jp = 4.2
    return 2.54/(1+exp((V-(-7.8-jp+lido_shift))/-10.68))
end

# ---- #

function h7_inf(V; shift::Float64=0.0, with_shift::Bool=false)
    # Lidocaine effect
    lido_shift = h7_shift(shift, with_shift)
    return alpha_h7(V; lido_shift=lido_shift) / (alpha_h7(V; lido_shift=lido_shift) + beta_h7(V; lido_shift=lido_shift))
end

function tau_h7(V)
    # Lidocaine effect
    lido_shift = 0.0
    return 1 / (alpha_h7(V; lido_shift=lido_shift) + beta_h7(V; lido_shift=lido_shift))
end

function m7_inf(V; shift::Float64=0.0, with_shift::Bool=false)
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

function dot_m7(V, m7; shift::Float64=0.0, with_shift::Bool=false)
    x_inf = m7_inf(V; shift=shift, with_shift=with_shift)
    tau_x = tau_m7(V)
    return (x_inf-m7)/tau_x
end

function dot_h7(V, h7; shift::Float64=0.0, with_shift::Bool=false)
    x_inf = h7_inf(V; shift=shift, with_shift=with_shift)
    tau_x = tau_h7(V)
    return (x_inf-h7)/tau_x
end
