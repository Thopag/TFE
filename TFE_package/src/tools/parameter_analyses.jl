
struct AnalyseData
    M_first_peak_h_w::Matrix{Tuple{Float32, Float32}}
    M_freq::Matrix{Float32}
    M_peak_count::Matrix{Int}
    M_pattern::Matrix{Int}
    M_limit_cycle_min_max::Matrix{Tuple{Float64, Float64}}
    VEC_rheobase::Vector{Union{Nothing,Float32}}
end


struct AnalyseResults
    nociceptor::Union{Nothing,AnalyseData}
    projection_neuron::Union{Nothing,AnalyseData}
    VEC_amp::Vector{Float64}
end

# --- init --- #

function analyse_data(n_row, n_col)

    M_first_peak_h_w = Matrix{Tuple{Float64, Float64}}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)
    M_limit_cycle_min_max = Matrix{Tuple{Float64, Float64}}(undef, n_row, n_col)

    VEC_rheobase = Vector{Union{Nothing,Float32}}(undef, n_col)

    return AnalyseData(M_first_peak_h_w, M_freq, M_peak_count, M_pattern, M_limit_cycle_min_max, VEC_rheobase)
end

function analyse_result(VEC_amp, VEC_p_model, with_nociceptor, with_projection_neuron)
    n_row = length(VEC_amp)
    n_col = length(VEC_p_model)

    n = nothing
    if with_nociceptor
        n = analyse_data(n_row, n_col)
    end

    pn = nothing
    if with_projection_neuron
        pn = analyse_data(n_row, n_col)
    end

    return AnalyseResults(n, pn, VEC_amp)
end

function analyse(sol, stim)

    t_spike = sol.t_spikes

    first_h, first_w = get_first_peak_height_and_width(sol.t, sol.V)
    freq, pattern = get_excitability(t_spike, stim.off)
    n_peak = length(t_spike)

    max = NaN64
    min = NaN64
    if pattern == 4
        # Get the voltage value in the last inter spike time
        V_last_spikes = @views sol.V[(sol.t .>= t_spike[end-1]) .& (sol.t .<= t_spike[end])]
        max = maximum(V_last_spikes)
        min = minimum(V_last_spikes)
    end

    return (first_h, first_w), freq, n_peak, pattern, (min, max)
end

function choose_analyse_simulation_function(results::AnalyseResults)

    with_nociceptor = !isnothing(results.nociceptor)
    with_projection_neuron = !isnothing(results.projection_neuron) 

    if with_nociceptor && with_projection_neuron
        simulation_function = with_synapse_simulation
    elseif with_nociceptor
        simulation_function = nociceptor_simulation
    elseif with_projection_neuron
        simulation_function = projection_neuron_simulation
    else
        prinln("(choose_simulation_function) I NEED AT LEAST A NEURON (nociceptor or projection neuron)")
    end
    return simulation_function
end

function make_analyse(amps_p_model, u0, i::Int, results::AnalyseResults; duration = 1700.0)

    L = length(amps_p_model)
    simulation = choose_analyse_simulation_function(results)

    for (j,p_model) in enumerate(amps_p_model)
        print("\rProgress: $(round(((j-1)/L*100), digits=2)) %")
        
        # Simulation
        stim = p_model.stimulation
        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), p_model)

        if !isnothing(sol_n)
            # Compute wanted features for nociceptor
            first_h_w, freq, n_peak, pattern, min_max = analyse(sol_n, stim)

            results.nociceptor.M_first_peak_h_w[j, i]      = first_h_w
            results.nociceptor.M_freq[j, i]                = freq
            results.nociceptor.M_peak_count[j, i]          = n_peak
            results.nociceptor.M_pattern[j, i]             = pattern
            results.nociceptor.M_limit_cycle_min_max[j, i] = min_max
        end

        if !isnothing(sol_pn)
            # Compute wanted features for projection neuron
            first_h_w, freq, n_peak, pattern, min_max = analyse(sol_pn, stim)

            results.projection_neuron.M_first_peak_h_w[j, i]      = first_h_w
            results.projection_neuron.M_freq[j, i]                = freq
            results.projection_neuron.M_peak_count[j, i]          = n_peak
            results.projection_neuron.M_pattern[j, i]             = pattern
            results.projection_neuron.M_limit_cycle_min_max[j, i] = min_max
        end

    end

    if !isnothing(results.nociceptor)
        # Search rheobase for nociceptor
        VEC_pattern = results.nociceptor.M_pattern[:, i]
        rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
        results.nociceptor.VEC_rheobase[i] = results.VEC_amp[rheobase_idx]
    end

    if !isnothing(results.projection_neuron)
        # Search rheobase for projection_neuron
        VEC_pattern = results.projection_neuron.M_pattern[:, i]
        rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
        results.projection_neuron.VEC_rheobase[i] = results.VEC_amp[rheobase_idx]
    end

    print("\r")
    return
end

function fill_analyse_result(i::Int, results::AnalyseResults, VEC_p_model, u0, VEC_label; duration = 1700.0)

    L = length(VEC_label)
    println("$(VEC_label[i]) -- $(round(((i-1)/L*100), digits=2)) % is done")

    p_model = VEC_p_model[i]

    VEC_stim = map( (amp) -> change_stimulation_amp(amp, p_model.stimulation), results.VEC_amp)
    amps_p_model = map( (stim) -> from_model_parameter(p_model; stimulation=stim), VEC_stim)

    make_analyse(amps_p_model, u0, i, results; duration = duration)

    return
end

function parameter_analyses(VEC_amp, fp::FileParameters)

    u0 = fp.u0
    duration = fp.duration
    VEC_p_model = fp.VEC_p_model
    VEC_label = fp.VEC_label
    
    results = analyse_result(VEC_amp, VEC_p_model, fp.with_nociceptor, fp.with_projection_neuron)
    for i in 1:length(VEC_p_model)
        fill_analyse_result(i, results, VEC_p_model, u0, VEC_label; duration = duration)
    end
    return results
end
