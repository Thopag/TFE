
# --------------------------- K_dr --------------------------- #

function alpha_ndr(V)
    return exp(1e-3*-5*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function alpha_ldr(V)
    return exp(1e-3*2*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

function beta_ndr(V)
    gmn = 0.4
    return exp(1e-3*-5*gmn*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function beta_ldr(V)
    gml = 1.0
    return exp(1e-3*2*gml*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

# ---- #

function ndr_inf(V)
    return 1/(1+alpha_ndr(V))
end

function tau_ndr(V)
    q10 = 3^((25-30)/10)
    return beta_ndr(V)/(q10*0.03*(1+alpha_ndr(V)))
end

function ldr_inf(V)
    return 1/(1+alpha_ldr(V))
end

function tau_ldr(V)
    q10 = 3^((25-30)/10)
    return beta_ldr(V)/(q10*0.001*(1 + alpha_ldr(V)))
end

# ---- #

function dot_ndr(V, ndr)
    return (ndr_inf(V)-ndr)/tau_ndr(V)
end

function dot_ldr(V, ldr)
    return (ldr_inf(V)-ldr)/tau_ldr(V)
end