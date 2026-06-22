

# ContinuousCallback event when the condition is == 0
# DiscreteCallback event when the condition is true

# ------------ spike detection ------------ #

function post_synaptic_spike_detection_condition(u,t,integrator)
    return u[12]  # u[12] is supposed to be V of the projection neuron
end

# projection_neuron_spike_detection_affect! defined in simulation_event.jl in projection_neuron
const cb_syn_pn_spike = ContinuousCallback(post_synaptic_spike_detection_condition, projection_neuron_spike_detection_affect!, nothing, save_positions=(true,false))

# ------------ delay spike response ------------ #

function NMDA_spike_response_condition(u,t,integrator)
  t_spikes = integrator.p.save.n_t_spikes
  # Check if had at least one spike
  L = length(t_spikes)
  if L == 0
    return false
  end

  s = integrator.p.synapse
  t_NMDA_response = integrator.p.save.t_NMDA_response
  # Check if it has not already started to response
  if length(t_NMDA_response) == L
    return false
  end
  # Check if the delay has passed
  if (t_spikes[end] + s.delay_NMDA) >= integrator.t
    return false
  end
  push!(integrator.p.save.t_NMDA_response, integrator.t)
  return true
end

function AMPA_spike_response_condition(u,t,integrator)
  t_spikes = integrator.p.save.n_t_spikes
  # Check if had at least one spike
  L = length(t_spikes)
  if L == 0
    return false
  end

  s = integrator.p.synapse
  t_AMPA_response = integrator.p.save.t_AMPA_response
  # Check if it has not already started to response
  if length(t_AMPA_response) == L
    return false
  end
  # Check if the delay has passed
  if (t_spikes[end] + s.delay_AMPA) >= integrator.t
    return false
  end
  push!(integrator.p.save.t_AMPA_response, integrator.t)
  return true
end

# ------------ synapse affect ------------ #

function NMDA_spike_response_affect!(integrator) 
    s = integrator.p.synapse

    i_A_NMDA = 17
    i_B_NMDA = 18
    i_Use_NMDA = 19
    i_P_NMDA = 20

    tp_NMDA = (s.tau_rise_NMDA * s.tau_decay_NMDA)/(s.tau_decay_NMDA-s.tau_rise_NMDA)*log(s.tau_decay_NMDA/s.tau_rise_NMDA)
    fact_NMDA = 1/(-exp(-tp_NMDA/s.tau_rise_NMDA)+exp(-tp_NMDA/s.tau_decay_NMDA))

    integrator.u[i_Use_NMDA] += s.U1_NMDA  * (1-integrator.u[i_Use_NMDA])
    integrator.u[i_A_NMDA] += s.w_NMDA   * fact_NMDA  * (integrator.u[i_Use_NMDA] * integrator.u[i_P_NMDA])
    integrator.u[i_B_NMDA] += s.w_NMDA   * fact_NMDA  * (integrator.u[i_Use_NMDA] * integrator.u[i_P_NMDA])
    integrator.u[i_P_NMDA] -= integrator.u[i_Use_NMDA] * integrator.u[i_P_NMDA]
end

function AMPA_spike_response_affect!(integrator) 
    s = integrator.p.synapse

    i_A_AMPA = 21
    i_B_AMPA = 22
    i_Use_AMPA = 23
    i_P_AMPA = 24

    tp_AMPA = (s.tau_rise_AMPA * s.tau_decay_AMPA)/(s.tau_decay_AMPA-s.tau_rise_AMPA)*log(s.tau_decay_AMPA/s.tau_rise_AMPA)
    fact_AMPA = 1/(-exp(-tp_AMPA/s.tau_rise_AMPA)+exp(-tp_AMPA/s.tau_decay_AMPA))

    integrator.u[i_Use_AMPA] += s.U1_AMPA  * (1-integrator.u[i_Use_AMPA])
    integrator.u[i_A_AMPA] += s.w_AMPA   * fact_AMPA  * (integrator.u[i_Use_AMPA] * integrator.u[i_P_AMPA])
    integrator.u[i_B_AMPA] += s.w_AMPA   * fact_AMPA  * (integrator.u[i_Use_AMPA] * integrator.u[i_P_AMPA])
    integrator.u[i_P_AMPA] -= integrator.u[i_Use_AMPA] * integrator.u[i_P_AMPA]
end

const cb_NMDA_spike_response = DiscreteCallback(NMDA_spike_response_condition, NMDA_spike_response_affect!,save_positions=(true,true))
const cb_AMPA_spike_response = DiscreteCallback(AMPA_spike_response_condition, AMPA_spike_response_affect!,save_positions=(true,true))