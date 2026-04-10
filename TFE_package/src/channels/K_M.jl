
# --------------------------- K_M --------------------------- #

function n_inf_K_M(V)
    return 1.0 / (1+exp(-(V-(-35))/5))
end

function tau_n_K_M(V)
    celsius = 25.0
    tadj = 3^((celsius-23.5)/10)
    return 1000.0/(3.3*(exp((V-(-35))/10)+exp(-(V+35)/10))) / tadj
end