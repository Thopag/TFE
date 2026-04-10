
# --------------------------- K_dr --------------------------- #

function alpha_n_K_dr(V)
    return exp(1e-3*-5*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function alpha_l_K_dr(V)
    return exp(1e-3*2*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

function beta_n_K_dr(V)
    gmn = 0.4
    return exp(1e-3*-5*gmn*(V+32)*9.648e4/(8.315*(273.16+25)))
end

function beta_l_K_dr(V)
    gml = 1.0
    return exp(1e-3*2*gml*(V-(-61))*9.648e4/(8.315*(273.16+25)))
end

# ---- #

function n_inf_K_dr(V)
    return 1/(1+alpha_n_K_dr(V))
end

function tau_n_K_dr(V)
    q10 = 3^((25-30)/10)
    return beta_n_K_dr(V)/(q10*0.03*(1+alpha_n_K_dr(V)))
end

function l_inf_K_dr(V)
    return 1/(1+alpha_l_K_dr(V))
end

function tau_l_K_dr(V)
    q10 = 3^((25-30)/10)
    return beta_l_K_dr(V)/(q10*0.001*(1 + alpha_l_K_dr(V)))
end