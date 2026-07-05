
struct FrequencyPlanData
    VEC_M_freq::Vector{Matrix{Float64}}
end

struct FrequencyPlanResults
    nociceptor::Union{Nothing,FrequencyPlanData}
    projection_neuron::Union{Nothing,FrequencyPlanData}
    VEC_amp::Vector{Float64}
end

function frequency_plan_data(L, n_row, n_col)

    VEC_M_freq = [fill(NaN, n_row, n_col) for _ in 1:L]
    return FrequencyPlanData(VEC_M_freq)
end

function frequency_plan_result(VEC_amp, M_p_model, with_nociceptor, with_projection_neuron)

    n_row, n_col = size(M_p_model)
    L = length(VEC_amp)

    n = nothing
    if with_nociceptor
        n = frequency_plan_data(L, n_row, n_col)
    end

    pn = nothing
    if with_projection_neuron
        pn = frequency_plan_data(L, n_row, n_col)
    end

    return FrequencyPlanResults(n, pn, VEC_amp)
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

function add_freq(VEC_amp, p_model, u0, i::Int, j::Int, results::FrequencyPlanResults, duration)

    stim = p_model.stimulation
    simulation  = choose_frequency_plan_simulation_function(results)

    for (k, amp) in enumerate(VEC_amp)
    
        new_stim = change_stimulation_amp(amp, stim)
        new_p_model = from_model_parameter(p_model; stimulation=new_stim)

        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), new_p_model)

        if !isnothing(sol_n)
            freq, pattern = get_excitability(sol_n.t_spikes, new_stim.off)
            if pattern != 0
                results.nociceptor.VEC_M_freq[k][i, j] = freq
            end
        end

        if !isnothing(sol_pn)
            freq, pattern = get_excitability(sol_pn.t_spikes, new_stim.off)
            if pattern != 0
                results.projection_neuron.VEC_M_freq[k][i, j] = freq
            end
        end
    end
    return
end

function fill_frequency_plan_result(i::Int, j::Int, results::FrequencyPlanResults, M_p_model, u0, duration)

    p_model = M_p_model[i, j]
    VEC_amp = results.VEC_amp

    n_row, n_col = size(M_p_model)
    println("\r Row : $(round((((i)-1)/n_row*100), digits=2)) % ----- Col : $(round((((j)-1)/n_col*100), digits=2)) %")

    add_freq(VEC_amp, p_model, u0, i, j, results, duration)

    print("\r")
    return
end

function frequency_plan(VEC_amp, pp::PlanParameters)

    u0 = pp.u0
    duration = pp.duration
    M_p_model = pp.M_p_model
    results = frequency_plan_result(VEC_amp, M_p_model, pp.with_nociceptor, pp.with_projection_neuron)
    for j in axes(M_p_model, 2)
        for i in axes(M_p_model, 1)
            fill_frequency_plan_result(i, j, results, M_p_model, u0, duration)
        end
    end
    return results
end