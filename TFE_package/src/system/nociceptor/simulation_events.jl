
# ContinuousCallback event when the condition is == 0
# DiscreteCallback event when the condition is true

# ------------ spike detection ------------ #

function spike_detection_condition(u,t,integrator)
    return u[1]  # u[1] is supposed to be V
end

function nociceptor_spike_detection_affect!(integrator)
    # Save the time and the amplitude of V at event
    # In the parameter's vectors
    save = integrator.p.save
    push!(save.n_t_spikes, integrator.t)
    push!(save.n_V_spikes, integrator.u[1]) 
end

const cb_n_spike = ContinuousCallback(spike_detection_condition, nociceptor_spike_detection_affect!, nothing, save_positions=(true,false))
