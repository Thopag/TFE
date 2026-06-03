
# --------------------------- K_dr --------------------------- #

function alpha_ndr(V::Float64)
    return exp(1e-3*-5*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function alpha_ldr(V::Float64)
    return exp(1e-3*2*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

function beta_ndr(V::Float64)
    gmn = 0.4
    return exp(1e-3*-5*gmn*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function beta_ldr(V::Float64)
    gml = 1.0
    return exp(1e-3*2*gml*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

# ---- #

function ndr_inf(V::Float64)
    return 1/(1+alpha_ndr(V))
end

function tau_ndr(V::Float64)
    q10 = 3^((25-30)/10)
    return beta_ndr(V)/(q10*0.03*(1+alpha_ndr(V)))
end

function ldr_inf(V::Float64)
    return 1/(1+alpha_ldr(V))
end

function tau_ldr(V::Float64)
    q10 = 3^((25-30)/10)
    return beta_ldr(V)/(q10*0.001*(1 + alpha_ldr(V)))
end

# ---- #

function dot_ndr(V::Float64, ndr::Float64)
    return (ndr_inf(V)-ndr)/tau_ndr(V)
end

function dot_ldr(V::Float64, ldr::Float64)
    return (ldr_inf(V)-ldr)/tau_ldr(V)
end