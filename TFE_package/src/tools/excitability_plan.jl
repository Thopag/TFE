
struct ExcitabilityPlanData
    M_rheobase::Matrix{Float64}
    M_spiking::Matrix{Float64}
end

struct ExcitabilityPlanResults
    nociceptor::Union{Nothing,ExcitabilityPlanData}
    projection_neuron::Union{Nothing,ExcitabilityPlanData}
    VEC_amp::Vector{Float64}
    M_p_model::Matrix{ModelParameters}
    VEC_row_param::Vector{Float64}
    VEC_col_param::Vector{Float64}
    row_label::String
    col_label::String
end

function excitability_plan_data(n_row, n_col)

    M_rheobase = fill(NaN64, n_row, n_col)
    M_spiking = fill(NaN64, n_row, n_col)
    return ExcitabilityPlanData(M_rheobase, M_spiking)
end

function excitability_plan_result(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, with_nociceptor, with_projection_neuron)

    n_row, n_col = size(M_p_model)
    n = nothing
    if with_nociceptor
        n = excitability_plan_data(n_row, n_col)
    end

    pn = nothing
    if with_projection_neuron
        pn = excitability_plan_data(n_row, n_col)
    end

    return ExcitabilityPlanResults(n, pn, VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label)
end

function choose_excitability_plan_simulation_function(results::ExcitabilityPlanResults)

    n_is_finded = 0
    pn_is_finded = 0

    with_nociceptor = !isnothing(results.nociceptor)
    with_projection_neuron = !isnothing(results.projection_neuron) 

    if with_nociceptor && with_projection_neuron
        simulation_function = with_synapse_simulation
    elseif with_nociceptor
        simulation_function = nociceptor_simulation
        pn_is_finded = 2
    elseif with_projection_neuron
        simulation_function = projection_neuron_simulation
        n_is_finded = 2
    else
        prinln("(choose_excitability_plan_simulation_function) I NEED AT LEAST A NEURON (nociceptor or projection neuron)")
    end
    return simulation_function, n_is_finded, pn_is_finded
end

function find_rheobase(amps, p_model, u0, i::Int, j::Int, results::ExcitabilityPlanResults; duration = 1700.0)

    stim = p_model.stimulation
    simulation, n_is_finded, pn_is_finded = choose_excitability_plan_simulation_function(results)

    L = length(amps)
    for (k,amp) in enumerate(amps)
        print("\rProgress: $(round(((k-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #
        i_stim = change_stimulation_amp(amp, stim)
        i_p_model = from_model_parameter(p_model; stimulation=i_stim)
        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), i_p_model)

        if (n_is_finded <= 1) && !isnothing(sol_n)
            # -- Get predicted pattern -- #
            _, pattern = get_excitability(sol_n.t_spikes, i_stim.off)

            # Check if there is at least one spike
            if (pattern >= 1) && (n_is_finded == 0)
                results.nociceptor.M_rheobase[i, j] = amp
                n_is_finded += 1
            end
            # Check if there is spiking
            if (pattern == 4)
                print("\r")
                results.nociceptor.M_spiking[i, j] = amp
                n_is_finded += 1
            end
        end

        if (pn_is_finded <= 1) && !isnothing(sol_pn)
            # Same as above but with projection neuron
            _, pattern = get_excitability(sol_n.t_spikes, i_stim.off)
            if (pattern >= 1) && (pn_is_finded == 0)
                results.projection_neuron.M_rheobase[i, j] = amp
                pn_is_finded += 1
            end
            if (pattern == 4)
                print("\r")
                results.projection_neuron.M_spiking[i, j] = amp
                pn_is_finded += 1
            end
        end

        # Finded all
        if (n_is_finded > 1) && (pn_is_finded > 1)
            return
        end

    end
    print("\r")
    return
end

function fill_excitability_plan_result(i::Int, j::Int, results::ExcitabilityPlanResults, u0; duration = 1700.0)

    p_model = results.M_p_model[i, j]
    VEC_amp = results.VEC_amp

    n_row, n_col = size(results.M_p_model)
    println("\r Row : $(round((((i)-1)/n_row*100), digits=2)) % ----- Col : $(round((((j)-1)/n_col*100), digits=2)) %")

    find_rheobase(VEC_amp, p_model, u0, i, j, results; duration = duration)

    print("\r")
    return
end

function excitability_plan(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, duration, u0; with_nociceptor=true, with_projection_neuron=false)

    results = excitability_plan_result(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, with_nociceptor, with_projection_neuron)
    for j in axes(M_p_model, 2)
        for i in axes(M_p_model, 1)
            fill_excitability_plan_result(i, j, results, u0; duration = duration)
        end
    end
    return results
end