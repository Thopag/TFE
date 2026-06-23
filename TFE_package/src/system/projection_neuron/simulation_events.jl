
# ContinuousCallback event when the condition is == 0
# DiscreteCallback event when the condition is true

# ------------ spike detection ------------ #

function projection_neuron_spike_detection_condition(u,t,integrator)
    i_V = integrator.p.idx.pn[1]
    return u[i_V]
end

function projection_neuron_spike_detection_affect!(integrator)
    i_V = integrator.p.idx.pn[1]
    # Save the time and the amplitude of V at event
    # In the parameter's vectors
    save = integrator.p.save
    push!(save.pn_t_spikes, integrator.t)
    push!(save.pn_V_spikes, integrator.u[i_V]) 
end

const cb_pn_spike = ContinuousCallback(projection_neuron_spike_detection_condition, projection_neuron_spike_detection_affect!, nothing, save_positions=(true,false))