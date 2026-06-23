
# ContinuousCallback event when the condition is == 0
# DiscreteCallback event when the condition is true

# ------------ spike detection ------------ #

function nociceptor_spike_detection_condition(u,t,integrator)
    i_V = integrator.p.idx.n[1]
    return u[i_V]
end

function nociceptor_spike_detection_affect!(integrator)
    i_V = integrator.p.idx.n[1]
    # Save the time and the amplitude of V at event
    # In the parameter's vectors
    save = integrator.p.save
    push!(save.n_t_spikes, integrator.t)
    push!(save.n_V_spikes, integrator.u[i_V]) 
end

const cb_n_spike = ContinuousCallback(nociceptor_spike_detection_condition, nociceptor_spike_detection_affect!, nothing, save_positions=(true,false))
