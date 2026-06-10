using Plots,LaTeXStrings,DifferentialEquations

heaviside(t)=0*(t<0)+1*(t>=0)
pulse(t,ti,tf)=heaviside(t-ti)-heaviside(t-tf)

function synapse(x,p)
    ## Fixed synaptic parameters
    eNMDA,eAMPA,U1_NMDA,tau_rise_NMDA,tau_decay_NMDA,tau_fac_NMDA,tau_rec_NMDA,U1_AMPA,tau_rise_AMPA,tau_decay_AMPA,tau_fac_AMPA,tau_rec_AMPA,ratio = p[1]

    ## Varying synaptic parameters
    gNMDA,gAMPA = p[2]

    ## Membrane potential 
    V_ = p[3][1]  

    ## Fixed parameters of membrane 
    C,eNa,eK,eCa,eleak,Ca_o,Ca_i_0,tau_Ca,d,Ra = p[4]

    ## State variables 
    A_NMDA_,B_NMDA_,Use_NMDA_,P_NMDA_,A_AMPA_,B_AMPA_,Use_AMPA_,P_AMPA_ =x

    ## Update equations
    dA_NMDA_ = -A_NMDA_/tau_rise_NMDA
    dB_NMDA_ = -B_NMDA_/tau_decay_NMDA
    dUse_NMDA_ = -Use_NMDA_/tau_fac_NMDA
    dP_NMDA_ = (1-P_NMDA_)/tau_rec_NMDA
    dA_AMPA_ = -A_AMPA_/tau_rise_AMPA
    dB_AMPA_ = -B_AMPA_/tau_decay_AMPA
    dUse_AMPA_ = -Use_AMPA_/tau_fac_AMPA
    dP_AMPA_ = (1-P_AMPA_)/tau_rec_AMPA

    ## Synaptic current computation
    INMDA_ = (B_NMDA_-A_NMDA_)*INMDA(gNMDA,V_,eNMDA)    # [µA/cm²]
    IAMPA_ = (B_AMPA_-A_AMPA_)*IAMPA(gAMPA,V_,eAMPA)    # [µA/cm²]
  
    Isyn_ = INMDA_ + IAMPA_  # [µA/cm²]
    
    ICa_from_syn = ratio*INMDA_ # [µA/cm²]

    dx_syn_ = [dA_NMDA_,dB_NMDA_,dUse_NMDA_,dP_NMDA_,dA_AMPA_,dB_AMPA_,dUse_AMPA_,dP_AMPA_]

    return Isyn_,ICa_from_syn,dx_syn_
end
function membrane(x,p)
    ## Global parameters
    I,k,F,L,D = p[1]

    ## Fixed parameters
    C,eNa,eK,eCa,eleak,Ca_o,Ca_i_0,tau_Ca,d,Ra = p[2]

    ## Varying intrinsic parameters 
	gNa,gKDR,gleak = p[3]

    ## Fixed synaptic parameters
	p_syn_fixed_ = p[4]

    ## Varying synaptic parameters -- should be an array of 0 for soma & AIS
	p_syn_var_ = p[5]

    if sum(abs.(p_syn_var_))>1e-10 
        ## State variables 
        V_,mNa_,hNa_,mKDR_,Ca_,
        A_NMDA_,B_NMDA_,Use_NMDA_,P_NMDA_,A_AMPA_,B_AMPA_,Use_AMPA_,P_AMPA_=x

        x_syn_ = [A_NMDA_,B_NMDA_,Use_NMDA_,P_NMDA_,A_AMPA_,B_AMPA_,Use_AMPA_,P_AMPA_]

        ## Synaptic current computation
        Isyn_,ICa_from_syn,dx_syn_ =  synapse(x_syn_,[p_syn_fixed_,p_syn_var_,V_,p[2]])
    else
        ## State variables 
        V_,mNa_,hNa_,mKDR_,Ca_=x

        ## Synaptic current computation
        Isyn_ = 0
        ICa_from_syn = 0
        dx_syn_ = []
    end

    ## Cellular current computation
    INa_ = INa(gNa,mNa_,hNa_,V_,eNa)
    IKDR_ = IKDR(gKDR,mKDR_,V_,eK)
    Ileak_ = Ileak(gleak,V_,eleak)
    Iion_ = INa_  +IKDR_  +Ileak_  # [µA/cm²]

    ## Update equations
    dV_ = (-Iion_-Isyn_)/C  # [mV/ms]

	dmNa_ = (mNa.(V_)-mNa_)/(tau_mNa.(V_))
	dhNa_ = (hNa.(V_)-hNa_)/(tau_hNa.(V_))
 	dmKDR_ = (mKDR.(V_)-mKDR_)/(tau_mKDR.(V_))
  
    dCa_ = dCa_from_ICa(0+ICa_from_syn,[p[1],p[2]]) - ((Ca_-Ca_i_0)/tau_Ca)

    dx = [dV_,dmNa_,dhNa_,dmKDR_,dCa_]
    append!(dx,dx_syn_) #adds the derivatives of the states defined for the synapse
    return dx
end
function dCa_from_ICa(ICa,p)
    ## Global parameters
    I,k,F,L,D = p[1]

    ## Fixed parameters
    C,eNa,eK,eCa,eleak,Ca_o,Ca_i_0,tau_Ca,d,Ra = p[2]

    ICa_ = (ICa)/1000  # [mA/cm^2] instead of [µA/cm^2]
    drive_channel = - ICa_ * k /(2*F*d)
    if drive_channel<=0
        dCa_from_ICa_ = 0 
    else
        dCa_from_ICa_ = - ICa_ * k /(2*F*d) 
    end
    return dCa_from_ICa_
end
function neuron!(du,u,p,t)
    ## Global parameters
    I,k,F,L,D = p[1]
    Inull(t) = 0
    p_glob_ = (Inull,k,F,L,D)

    ## Fixed parameters 
    p_fixed_ = p[2][1][1]
    Cm = p_fixed_[1]
    Ra = p_fixed_[end]
    ## Varying intrinsic parameters 
	p_var_= p[2][1][2]
    ## Fixed synaptic parameters
	p_syn_fixed_ = p[2][2][1]
    ## Varying synaptic parameters -- should be an array of 0 for soma & AIS
	p_syn_var_ = p[2][2][2]

    ## Connectivity parameters
    p_conn_w_ = p[3][1]  #w_NMDA,w_AMPA -- should be an array of 0 if no presynaptic neuron
    p_conn_d_  = p[3][2] #d_NMDA,d_AMPA

    ## Indices of states 
    p_indices_ = p[4]
    i_dV_ = p_indices_[1][1]
    i_Ca_ = p_indices_[2][1]
    i_xsyn_ = p_indices_[3]
    if maximum(i_xsyn_)==0
        i_x_end = i_Ca_
    else
        i_x_end = maximum(i_xsyn_)
    end

    ## Surface areas
    Sm = 2*pi*(D/2)*L *10^(-8) # [cm²]

    ## Gradients 
	dx = membrane(u[Int(i_dV_):Int(i_x_end)],[p_glob_,p_fixed_,p_var_,p_syn_fixed_,p_syn_var_])
    dV_ = dx[1]
    du[Int(i_dV_+1):Int(i_dV_+length(dx)-1)] = dx[2:end]

    du[i_dV_]=  dV_ + I(t)/(Cm*Sm) 
end

function network!(du,u,p,t)
    ## Global parameters
    p_glob_n1= p[1][1]
    ## Fixed parameters 
    p_fixed_n1 = p[1][2][1][1]
    ## Varying intrinsic parameters 
	p_var_n1= p[1][2][1][2]
    ## Fixed synaptic parameters
	p_syn_fixed_n1 = p[1][2][2][1]
    ## Varying synaptic parameters -- should be an array of 0 for soma & AIS
	p_syn_var_n1 = p[1][2][2][2]
    ## Connectivity parameters
    p_conn_w_n1 = p[1][3][1]  #w_NMDA,w_AMPA -- should be an array of 0 if no presynaptic neuron
    p_conn_d_n1  = p[1][3][2] #d_NMDA,d_AMPA


    ## Global parameters
    p_glob_n2= p[2][1]
    ## Fixed parameters 
    p_fixed_n2 = p[2][2][1][1]
    ## Varying intrinsic parameters 
	p_var_n2= p[2][2][1][2]
    ## Fixed synaptic parameters
	p_syn_fixed_n2 = p[2][2][2][1]
    ## Varying synaptic parameters -- should be an array of 0 for soma & AIS
	p_syn_var_n2 = p[2][2][2][2]
    ## Connectivity parameters
    p_conn_w_n2 = p[2][3][1]  #w_NMDA,w_AMPA -- should be an array of 0 if no presynaptic neuron
    p_conn_d_n2  = p[2][3][2] #d_NMDA,d_AMPA


    ## Indices of states 
    p_indices_ = p[3]
    p_indices_n1_,p_indices_n2_ = p_indices_

    ## n1
    p_n1_ = [p_glob_n1,[[p_fixed_n1,p_var_n1],[p_syn_fixed_n1,p_syn_var_n1]],[p_conn_w_n1,p_conn_d_n1],p_indices_n1_]
    neuron!(du,u,p_n1_,t)

    ## n2
    p_n2_ = [p_glob_n2,[[p_fixed_n2,p_var_n2],[p_syn_fixed_n2,p_syn_var_n2]],[p_conn_w_n2,p_conn_d_n2],p_indices_n2_]
    neuron!(du,u,p_n2_,t)
end



   