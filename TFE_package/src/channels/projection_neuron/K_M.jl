
# --------------------------- K_M --------------------------- #

function mM_inf(V)
    return 1.0 / ( 1.0 + exp( (-V-76.1)/25.7 ) )
end

function tau_mM(V)
    return 103
end

# ---- #

function dot_mM(V, mM)
    x_inf = mM_inf(V)
    tau_x = tau_mM(V)
    return (x_inf-mM)/tau_x
end