
struct FrequencyPlanData
    M_freq::Matrix{Float64}
end

struct FrequencyPlanResults
    nociceptor::Union{Nothing,FrequencyPlanData}
    projection_neuron::Union{Nothing,FrequencyPlanData}
    amp::Float64
end

function frequency_plan_data(n_row, n_col)

    M_freq = fill(NaN64, n_row, n_col)
    return FrequencyPlanData(M_freq)
end

function frequency_plan_result(amp, M_p_model, with_nociceptor, with_projection_neuron)

    n_row, n_col = size(M_p_model)
    n = nothing
    if with_nociceptor
        n = frequency_plan_data(n_row, n_col)
    end

    pn = nothing
    if with_projection_neuron
        pn = frequency_plan_data(n_row, n_col)
    end

    return FrequencyPlanResults(n, pn, amp)
end

function choose_frequency_plan_simulation_function(results::FrequencyPlanResults)

    with_nociceptor = !isnothing(results.nociceptor)
    with_projection_neuron = !isnothing(results.projection_neuron) 

    if with_nociceptor && with_projection_neuron
        simulation_function = with_synapse_simulation
    elseif with_nociceptor
        simulation_function = nociceptor_simulation
    elseif with_projection_neuron
        simulation_function = projection_neuron_simulation
    else
        prinln("(choose_frequency_plan_simulation_function) I NEED AT LEAST A NEURON (nociceptor or projection neuron)")
    end
    return simulation_function
end

function add_freq(amp, p_model, u0, i::Int, j::Int, results::FrequencyPlanResults, duration)

    stim = p_model.stimulation
    simulation  = choose_frequency_plan_simulation_function(results)

    new_stim = change_stimulation_amp(amp, stim)
    new_p_model = from_model_parameter(p_model; stimulation=new_stim)

    sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), new_p_model)

    if !isnothing(sol_n)
        freq, pattern = get_excitability(sol_n.t_spikes, new_stim.off)
        if pattern != 0
            results.nociceptor.M_freq[i, j] = freq
        end
    end

    if !isnothing(sol_pn)
        freq, pattern = get_excitability(sol_pn.t_spikes, new_stim.off)
        if pattern != 0
            results.projection_neuron.M_freq[i, j] = freq
        end
    end
    return
end

function fill_frequency_plan_result(i::Int, j::Int, results::FrequencyPlanResults, M_p_model, u0, duration)

    p_model = M_p_model[i, j]
    amp = results.amp

    n_row, n_col = size(M_p_model)
    println("\r Row : $(round((((i)-1)/n_row*100), digits=2)) % ----- Col : $(round((((j)-1)/n_col*100), digits=2)) %")

    add_freq(amp, p_model, u0, i, j, results, duration)

    print("\r")
    return
end

function frequency_plan(amp, pp::PlanParameters)

    u0 = pp.u0
    duration = pp.duration
    M_p_model = pp.M_p_model
    results = frequency_plan_result(amp, M_p_model, pp.with_nociceptor, pp.with_projection_neuron)
    for j in axes(M_p_model, 2)
        for i in axes(M_p_model, 1)
            fill_frequency_plan_result(i, j, results, M_p_model, u0, duration)
        end
    end
    return results
end