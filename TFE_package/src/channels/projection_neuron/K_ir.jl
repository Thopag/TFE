
# --------------------------- K_ir --------------------------- #

function mir_inf(V)
    return 1.0 / ( 1.0 + exp((V+65.0)/10.0) )
end

function tau_mir(V)
    return 10.0
end

# ---- #

function dot_mir(V, mir)
    x_inf = mir_inf(V)
    tau_x = tau_mir(V)
    return (x_inf-mir)/tau_x
end