
# --------------------------- AHP --------------------------- #

function z_AHP_inf(V)
    beta_z_AHP = 5
    gamma_z =  4
    return 1 / ( 1 + exp( (beta_z_AHP - V)/gamma_z ) ) 
end

function tau_z_AHP(V)
    return 100
end