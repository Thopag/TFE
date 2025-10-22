# --------------------------- Common to Na_V 1.7, Na_V 1.3, Na_V 1.8 --------------------------- #

function dot_m(V, m, alpha, beta)
    return alpha(V)*(1-m) - m*beta(V)
end

function dot_h(V, h, alpha, beta)
    return alpha(V)*(1-h) - h*beta(V)
end

# --------------------------- Na_V 1.7 --------------------------- #

function alpha_m_1_7(V)
    return 10.22 - ( 10.22 / ( 1 + exp( (V+7.19)/15.43 ) ) )
end

function alpha_h_1_7(V)
    return 0.0744 / ( 1 + exp( (V+99.76)/11.07 ) )
end

function beta_m_1_7(V)
    return 23.76 / ( 1 + exp( (V+70.37)/14.53 ) )
end

function beta_h_1_7(V)
    return 2.54 - ( 2.54 / ( 1 + exp( (V+7.8)/10.68 ) ) )
end

# --------------------------- Na_V 1.3 --------------------------- #

function alpha_m_1_3(V)
    return 10.22 - ( 10.22 / ( 1 + exp( (V+7.19+12)/15.43 ) ) )
end

function alpha_h_1_3(V)
    return 0.0744 / ( 1 + exp( (V+99.76)/11.07 ) )
end

function beta_m_1_3(V)
    return 23.76 / ( 1 + exp( (V+70.37+12)/14.53 ) )
end

function beta_h_1_3(V)
    return 2.54 - ( 2.54 / ( 1 + exp( (V+7.8)/10.68 ) ) )
end

# --------------------------- Na_V 1.8 --------------------------- #

function alpha_m_1_8(V)
    return 7.21 - ( 7.21 / ( 1 + exp( (V-0.063)/7.86 ) ) )
end

function alpha_h_1_8(V)
    return 0.003 + ( 1.63 / ( 1 + exp( (V+68.5)/10.01 ) ) )
end

function beta_m_1_8(V)
    return 7.4 / ( 1 + exp( (V+53.06)/19.34 ) )
end

function beta_h_1_8(V)
    return 0.81 - ( 0.81 / ( 1 + exp( (V-11.44)/13.12 ) ) )
end

# --------------------------- K_M --------------------------- #

function n_inf_K_M(V)
    return 1000 / ( 1 + exp( -(V+35)/5 ) )
end

function tau_n_K_M(V)
    return 1000 / ( ( 3.3 * exp( V + (35/10) ) ) + exp( -(V+35)/10 )  )
end

function dot_n_K_M(V, n)
    return ( n_inf_K_M(V) - n ) / tau_n_K_M(V)
end

# --------------------------- K_dr --------------------------- #

function alpha_n_K_dr(V)
    return exp( - 5e-3 * (V+32) * 9.648e4 ) / 2562.35
end

function alpha_l_K_dr(V)
    return exp( 2e-3 * (V+61) * 9.648e4 ) / 2562.35
end

function beta_n_K_dr(V)
    return exp( - 2e-3 * (V+32) * 9.648e4 ) / 2562.35
end

function beta_l_K_dr(V)
    return exp( - 2e-3 * (V+32) * 9.648e4 ) / 2562.35
end

function dot_n_K_dr(V, n)
    return alpha_n_K_dr(V)*(1-n) - n*beta_n_K_dr(V)
end

function dot_l_K_dr(V, l)
    return alpha_l_K_dr(V)*(1-l) - l*beta_l_K_dr(V)
end

# --------------------------- AHP --------------------------- #

function dot_z_AHP(V, z)
    return ( 1 / ( 1 + exp( 5 - (V/4) ) ) ) - ( z/100 )
end
