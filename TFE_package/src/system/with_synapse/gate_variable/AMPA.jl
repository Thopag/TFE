
# --------------------------- AMPA --------------------------- #

function dot_A_AMPA(A_AMPA, tau_rise_AMPA)
    return -A_AMPA/tau_rise_AMPA
end

function dot_B_AMPA(B_AMPA, tau_decay_AMPA)
    return -B_AMPA/tau_decay_AMPA
end

function dot_Use_AMPA(Use_AMPA, tau_fac_AMPA)
    return -Use_AMPA/tau_fac_AMPA
end

function dot_P_AMPA(P_AMPA, tau_rec_AMPA)
    return (1-P_AMPA)/tau_rec_AMPA
end