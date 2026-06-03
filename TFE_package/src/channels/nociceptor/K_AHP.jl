
# --------------------------- K_AHP --------------------------- #

function zAHP_inf(V)
    beta_z_AHP = 5
    gamma_z =  4
    return 1 / ( 1 + exp( (beta_z_AHP - V)/gamma_z ) ) 
end

function tau_zAHP(V)
    return 100
end

# ---- #

function dot_zAHP(V, zAHP)
    return (zAHP_inf(V)-zAHP)/tau_zAHP(V)
end

