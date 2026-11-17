export CurrentPlanData, CurrentPlanResults

struct CurrentPlanData
    M_rheobase::Matrix{Float64}
    M_spiking::Matrix{Float64}
    M_rheo_h::Matrix{Float64}
    M_rheo_w::Matrix{Float64}
    M_s_init_freq::Matrix{Float64}
    M_s_sust_freq::Matrix{Float64}
end

struct CurrentPlanResults
    nociceptor::Union{Nothing,CurrentPlanData}
    projection_neuron::Union{Nothing,CurrentPlanData}
    VEC_amp::Vector{Float64}
end

function current_plan_data(n_row, n_col)

    M_rheobase = fill(NaN64, n_row, n_col)
    M_spiking = fill(NaN64, n_row, n_col)
    M_rheo_h = fill(NaN64, n_row, n_col)
    M_rheo_w = fill(NaN64, n_row, n_col)
    M_s_init_freq = fill(NaN64, n_row, n_col)
    M_s_sust_freq = fill(NaN64, n_row, n_col)

    return CurrentPlanData(M_rheobase, M_spiking, M_rheo_h, M_rheo_w, M_s_init_freq, M_s_sust_freq)
end

function current_plan_result(VEC_amp, M_p_model, with_nociceptor, with_projection_neuron)

    n_row, n_col = size(M_p_model)
    n = nothing
    if with_nociceptor
        n = current_plan_data(n_row, n_col)
    end

    pn = nothing
    if with_projection_neuron
        pn = current_plan_data(n_row, n_col)
    end

    return CurrentPlanResults(n, pn, VEC_amp)
end

function find_current(amps, p_model, u0, i::Int, j::Int, results::CurrentPlanResults, duration)

    idx_rheo = find_rheobase(amps, p_model, u0, duration)
    idx_spiking = find_spiking(amps, idx_rheo, p_model, u0, duration)

    stim = p_model.stimulation
    simulation = choose_simulation_function(!isnothing(results.nociceptor), !isnothing(results.projection_neuron))
    
    if !isnothing(idx_rheo)
        rheo_stim = change_stimulation_amp(amps[idx_rheo], stim)
        rheo_p_model = from_model_parameter(p_model; stimulation=rheo_stim)
        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), rheo_p_model)

        if !isnothing(sol_n)
            results.nociceptor.M_rheobase[i, j] = amps[idx_rheo]

            h, w = get_first_peak_height_and_width(sol_n.t, sol_n.V)
            results.nociceptor.M_rheo_h[i, j] = h
            results.nociceptor.M_rheo_w[i, j] = w
        end

        if !isnothing(sol_pn)
            results.projection_neuron.M_rheobase[i, j] = amps[idx_rheo]

            h, w = get_first_peak_height_and_width(sol_pn.t, sol_pn.V)
            results.projection_neuron.M_rheo_h[i, j] = h
            results.projection_neuron.M_rheo_w[i, j] = w
        end
    end

    if !isnothing(idx_spiking)
        spiking_stim = change_stimulation_amp(amps[idx_spiking], stim)
        spiking_p_model = from_model_parameter(p_model; stimulation=spiking_stim)
        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), spiking_p_model)

        if !isnothing(sol_n)
            results.nociceptor.M_spiking[i, j] = amps[idx_spiking]

            init_freq, sust_freq, _ = get_firing_pattern(sol_n.t_spikes, spiking_stim.off)
            results.nociceptor.M_s_init_freq[i, j] = init_freq
            results.nociceptor.M_s_sust_freq[i, j] = sust_freq
        end

        if !isnothing(sol_pn)
            results.projection_neuron.M_spiking[i, j] = amps[idx_spiking]

            init_freq, sust_freq, _ = get_firing_pattern(sol_pn.t_spikes, spiking_stim.off)
            results.projection_neuron.M_s_init_freq[i, j] = init_freq
            results.projection_neuron.M_s_sust_freq[i, j] = sust_freq
        end
    end

    print("\r")
    return
end

function fill_current_plan_result(i::Int, j::Int, results::CurrentPlanResults, M_p_model, u0, duration)

    p_model = M_p_model[i, j]
    VEC_amp = results.VEC_amp

    n_row, n_col = size(M_p_model)
    println("Row : $(round((((i)-1)/n_row*100), digits=2)) % ----- Col : $(round((((j)-1)/n_col*100), digits=2)) %")

    find_current(VEC_amp, p_model, u0, i, j, results, duration)

    return
end

function current_plan(VEC_amp, pp::File2D)

    u0 = pp.u0
    duration = pp.duration
    M_p_model = pp.M_p_model
    results = current_plan_result(VEC_amp, M_p_model, pp.with_nociceptor, pp.with_projection_neuron)
    for j in axes(M_p_model, 2)
        for i in axes(M_p_model, 1)
            fill_current_plan_result(i, j, results, M_p_model, u0, duration)
        end
    end
    return results
end