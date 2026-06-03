
# --------------------------- K_AHP --------------------------- #

function zAHP_inf(V::Float64)
    beta_z_AHP = 5
    gamma_z =  4
    return 1 / ( 1 + exp( (beta_z_AHP - V)/gamma_z ) ) 
end

function tau_zAHP(V::Float64)
    return 100
end

# ---- #

function dot_zAHP(V::Float64, zAHP::Float64)
    return (zAHP_inf(V)-zAHP)/tau_zAHP(V)
end

