
# --------------------------- K_M --------------------------- #

function nM_inf(V)
    return 1.0 / (1+exp(-(V-(-35))/5))
end

function tau_nM(V)
    celsius = 25.0
    tadj = 3^((celsius-23.5)/10)
    return 1000.0/(3.3*(exp((V-(-35))/10)+exp(-(V+35)/10))) / tadj
end

# ---- #

function dot_nM(V, nM)
    return (nM_inf(V)-nM)/tau_nM(V)
end