#-------------------------------------------------------------------------------
#                            UPDATE FUNCTIONS
#
#-------------------------------------------------------------------------------
## Condition to update state after a fixed delay when spikes are detected
  function condition(u, t, integrator, delay, t_inc) 
    if length(t_inc)==0
        return length(ts)>0 && length(t_inc) != length(ts) && minimum(abs.((ts.+delay).-t))<dt_  
    else
        return length(ts)>0 && length(t_inc) != length(ts) && minimum(abs.((ts.+delay).-t))<dt_ && !(t in t_inc) && abs(t-t_inc[end])>2*dt_
    end
  end

function inc_syn_NMDA_states_n!(integrator,p_syn_fixed_,p_conn_w_,i_syn_r_i_) 
    eNMDA,eAMPA,U1_NMDA,tau_rise_NMDA,tau_decay_NMDA,tau_fac_NMDA,tau_rec_NMDA,U1_AMPA,tau_rise_AMPA,tau_decay_AMPA,tau_fac_AMPA,tau_rec_AMPA,ratio = p_syn_fixed_ #integrator.p[2][4][1]

    w_NMDA,w_AMPA = p_conn_w_ #integrator.p[3][1][1]

    if length(i_syn_r_i_)>1 && abs(w_NMDA)>0
      i_A_NMDA,i_B_NMDA,i_Use_NMDA,i_P_NMDA,i_A_AMPA,i_B_AMPA,i_Use_AMPA,i_P_AMPA =i_syn_r_i_[1:end] #last states are mGRPR, minh and mKir, but not modified by events directly

      tp_NMDA = (tau_rise_NMDA*tau_decay_NMDA)/(tau_decay_NMDA-tau_rise_NMDA)*log(tau_decay_NMDA/tau_rise_NMDA)
      fact_NMDA = 1/(-exp(-tp_NMDA/tau_rise_NMDA)+exp(-tp_NMDA/tau_decay_NMDA))
      
      integrator.u[i_Use_NMDA] +=  U1_NMDA*(1-integrator.u[i_Use_NMDA]) 
      integrator.u[i_A_NMDA] += w_NMDA*fact_NMDA*(integrator.u[i_Use_NMDA] * integrator.u[i_P_NMDA])
      integrator.u[i_B_NMDA] += w_NMDA*fact_NMDA*(integrator.u[i_Use_NMDA] * integrator.u[i_P_NMDA])
      integrator.u[i_P_NMDA] -= integrator.u[i_Use_NMDA] *integrator.u[i_P_NMDA]
    end
end

function inc_syn_AMPA_states_n!(integrator,p_syn_fixed_,p_conn_w_,i_syn_r_i_) 
    eNMDA,eAMPA,U1_NMDA,tau_rise_NMDA,tau_decay_NMDA,tau_fac_NMDA,tau_rec_NMDA,U1_AMPA,tau_rise_AMPA,tau_decay_AMPA,tau_fac_AMPA,tau_rec_AMPA,ratio = p_syn_fixed_ #integrator.p[2][4][1]

    w_NMDA,w_AMPA = p_conn_w_ #integrator.p[3][1][1]

    if length(i_syn_r_i_)>1 && abs(w_AMPA)>0
      i_A_NMDA,i_B_NMDA,i_Use_NMDA,i_P_NMDA,i_A_AMPA,i_B_AMPA,i_Use_AMPA,i_P_AMPA =i_syn_r_i_[1:end] #last states are mGRPR, minh and mKir, but not modified by events directly
    
      tp_AMPA = (tau_rise_AMPA*tau_decay_AMPA)/(tau_decay_AMPA-tau_rise_AMPA)*log(tau_decay_AMPA/tau_rise_AMPA)
      fact_AMPA = 1/(-exp(-tp_AMPA/tau_rise_AMPA)+exp(-tp_AMPA/tau_decay_AMPA))
    
      integrator.u[i_Use_AMPA] +=  U1_AMPA*(1-integrator.u[i_Use_AMPA])
      integrator.u[i_A_AMPA] += w_AMPA*fact_AMPA*(integrator.u[i_Use_AMPA] * integrator.u[i_P_AMPA])
      integrator.u[i_B_AMPA] += w_AMPA*fact_AMPA*(integrator.u[i_Use_AMPA] * integrator.u[i_P_AMPA])
      integrator.u[i_P_AMPA] -= integrator.u[i_Use_AMPA] *integrator.u[i_P_AMPA]
    end
end



#-------------------------------------------------------------------------------
#                          CALLBACKS DEFINITION
#
#-------------------------------------------------------------------------------
## Spike detection in axon of n1
  global ts = []
  function spike_appears(u,t,integrator) # Event when event_f(u,t) == 0
    p_indices_1_ = integrator.p[3][1]
    i_dV_1_= p_indices_1_[1][1]
    return u[i_dV_1_]  
  end
  function save_time_spike_appears!(integrator) 
    push!(ts,integrator.t) #saves the time of the event 
  end
  cb_spike = ContinuousCallback(spike_appears,save_time_spike_appears!,nothing,save_positions=(true,false));

## Last time step detection to all model state variables 
  global u_tf = []
  function last_time_step(u,t,integrator) # Event when event_f(u,t) == 0
    return t-t_win 
  end
  function save_all_states!(integrator) 
    push!(u_tf,integrator.u) #saves the time of the event 
  end
  cb_tf = ContinuousCallback(last_time_step,save_all_states!,nothing,save_positions=(true,false));


## Define a set of conditions and update function to detect the end of the delay required for each update of the states of the synaptic channel 
## Synaptic process having the same delay will be updated within the same function 
  global t_inc = []
  cond_ = []
  cond = []
  inc=[]
  for delay_ in unique(p_conn_d___n1_to_n2) # p_conn_d___n1_to_n2 is a vector of delays for spike arrival in postsynaptic domain
      push!(t_inc,[])
      condition_on_delay_(u,t,integrator,t_inc_) = condition(u,t,integrator,delay_,t_inc_)
      push!(cond_,condition_on_delay_)
      inc_for_given_delay = []
      for i in eachindex(p_conn_d___n1_to_n2)
        if p_conn_d___n1_to_n2[i]==delay_ 
          if i==1
            push!(inc_for_given_delay,inc_syn_NMDA_states_n!)
          end
          if i==2
            push!(inc_for_given_delay,inc_syn_AMPA_states_n!)
          end
        end
      end
      push!(inc,inc_for_given_delay)
  end

  for i in eachindex(cond_)
    condition_on_delay(u,t,integrator) = cond_[i](u,t,integrator,t_inc[i])
    push!(cond,condition_on_delay)
  end

## Defines callbacks for synaptic updates, consistently with each delay 
  merged_inc = []
  cb_inc_syn_l = []
  for i in eachindex(inc)
    println("-------")
    function merge_inc_for_cond_i!(integrator)
      p_syn_fixed_n2_ = integrator.p[2][2][2][1]
      p_conn_w_n2_ = integrator.p[2][3][1]
      p_indices_n2_ = integrator.p[3][2]
      i_syn_r_n2_ = p_indices_n2_[3]
      for inc_ in inc[i]
        inc_(integrator,p_syn_fixed_n2_,p_conn_w_n2_,i_syn_r_n2_)
      end
      push!(t_inc[i],integrator.t)
    end
    push!(merged_inc,merge_inc_for_cond_i!)
    cb_inc_syn_i_ =DiscreteCallback(cond[i], merge_inc_for_cond_i!,save_positions=(true,true))
    push!(cb_inc_syn_l,cb_inc_syn_i_)
  end

## Put all callbacks together
  all_cb = []
  push!(all_cb,cb_spike)
  for i in eachindex(cb_inc_syn_l)
    push!(all_cb,cb_inc_syn_l[i])
  end
  #push!(all_cb,cb_tf)
  cbs = CallbackSet(all_cb...)


