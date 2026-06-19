

function dot_A_NMDA(A_NMDA, tau_rise_NMDA)
    return -A_NMDA/tau_rise_NMDA
end

function dot_B_NMDA(B_NMDA, tau_decay_NMDA)
    return -B_NMDA/tau_decay_NMDA
end

function dot_Use_NMDA(Use_NMDA, tau_fac_NMDA)
    return -Use_NMDA/tau_fac_NMDA
end

function dot_P_NMDA(P_NMDA, tau_rec_NMDA)
    return (1-P_NMDA)/tau_rec_NMDA
end

# Not used
function NMDA_Mg_block(V) 
    mgo = 1.0               #[mM]
    m = 1 / (1 + exp(0.062 * -V) * (mgo / 3.57 ))
    return m
end