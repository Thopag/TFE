
struct SSCurrentResults
    V::Vector{Float64}
    VEC_nociceptor::Vector{NociceptorCurrent}
    VEC_projection_neuron::Vector{ProjectionNeuronCurrent}
end

function SS_current_result(V, VEC_p_model)

    L = length(VEC_p_model)
    VEC_nociceptor  = Vector{NociceptorCurrent}(undef, L)
    VEC_projection_neuron = Vector{ProjectionNeuronCurrent}(undef, L)
    return SSCurrentResults(V, VEC_nociceptor, VEC_projection_neuron)
end

function make_SS_current(V, p_model)
    n  = nociceptor_SS_currents(V, p_model)
    pn = projection_neuron_SS_currents(V, p_model)
    return n, pn
end

function fill_SS_current_result(i::Int, results::SSCurrentResults, VEC_p_model)

    p_model = VEC_p_model[i]
    n, pn = make_SS_current(results.V, p_model)

    results.VEC_nociceptor[i] = n
    results.VEC_projection_neuron[i] = pn
    return
end

function SS_current_analyses(V, fp::FileParameters)

    VEC_p_model = fp.VEC_p_model
    results = SS_current_result(V, VEC_p_model)
    for i in 1:length(VEC_p_model)
        fill_SS_current_result(i, results, VEC_p_model)
    end
    return results
end