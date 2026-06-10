
function indices_states(p_syn_var_n1,p_syn_var_n2)
    if sum(abs.(p_syn_var_n1))>1e-10 
        n_mem_1 = 5 #number of states in membrane(x,p) from compartment_events.jl
        n_syn_1 = 8 #number of states in synapse(x,p) from compartment_events.jl

        i_dx_syn_1_start = n_mem_1+1
        i_dx_syn_1_end = i_dx_syn_1_start+n_syn_1-1
    else
        n_mem_1 = 5 #number of states in membrane(x,p) from compartment_events.jl
        n_syn_1 = 0

        i_dx_syn_1_start = 0
        i_dx_syn_1_end = 0
    end

    i_dV_n1 = 1

    i_Ca_n1 = i_dV_n1+n_mem_1-1

    N_1 = i_Ca_n1 + n_syn_1

    if sum(abs.(p_syn_var_n2))>1e-10 
        n_mem_2 = 5 #number of states in membrane(x,p) from compartment_events.jl
        n_syn_2 = 8 #number of states in synapse(x,p) from compartment_events.jl

        i_dx_syn_2_start = N_1+n_mem_2+1
        i_dx_syn_2_end = i_dx_syn_2_start+n_syn_2-1
    else
        n_mem_2 = 5 #number of states in membrane(x,p) from compartment_events.jl
        n_syn_2 = 0

        i_dx_syn_2_start = 0
        i_dx_syn_2_end = 0
    end

    
    i_dV_n2 = N_1+1

    i_Ca_n2 = i_dV_n2 + n_mem_2-1

    N_2 = i_Ca_n2 + n_syn_2


    i_V_1 = [i_dV_n1]
    i_V_2 = [i_dV_n2]
    
    i_Ca_1 = [i_Ca_n1]
    i_Ca_2 = [i_Ca_n2]

    i_syn_r_1 = collect(i_dx_syn_1_start:i_dx_syn_1_end)
    i_syn_r_2 = collect(i_dx_syn_2_start:i_dx_syn_2_end)

    i_n1 = [i_V_1,i_Ca_1,i_syn_r_1]
    i_n2 = [i_V_2,i_Ca_2,i_syn_r_2]

    return [i_n1,i_n2]
end
