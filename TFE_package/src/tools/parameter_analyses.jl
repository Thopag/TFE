
struct AnalyseData
    M_first_peak_h::Matrix{Float32}
    M_first_peak_w::Matrix{Float32}
    M_init_freq::Matrix{Float32}
    M_sust_freq::Matrix{Float32}
    M_peak_count::Matrix{Int}
    M_pattern::Matrix{Int}
end

struct AnalyseResults
    nociceptor::Union{Nothing,AnalyseData}
    projection_neuron::Union{Nothing,AnalyseData}
    VEC_amp::Vector{Float64}
end

# --- init --- #

function analyse_data(n_row, n_col)

    M_first_peak_h = Matrix{Float32}(undef, n_row, n_col)
    M_first_peak_w = Matrix{Float32}(undef, n_row, n_col)
    M_init_freq = Matrix{Float32}(undef, n_row, n_col)
    M_sust_freq = Matrix{Float32}(undef, n_row, n_col)
    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)

    return AnalyseData(M_first_peak_h, M_first_peak_w, M_init_freq, M_sust_freq, M_peak_count, M_pattern)
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
    init_freq, sust_freq, pattern = get_firing_pattern(t_spike, stim.off)
    n_peak = length(t_spike)

    return first_h, first_w, init_freq, sust_freq, n_peak, pattern
end

function make_analyse(amps_p_model, u0, i::Int, results::AnalyseResults; duration = 1700.0)

    L = length(amps_p_model)
    simulation = choose_simulation_function(!isnothing(results.nociceptor), !isnothing(results.projection_neuron))

    for (j,p_model) in enumerate(amps_p_model)
        print("\rProgress: $(round(((j-1)/L*100), digits=2)) %")
        
        # Simulation
        stim = p_model.stimulation
        sol_n, sol_pn, sol_s = simulation(u0, (0.0, duration), p_model)

        if !isnothing(sol_n)
            # Compute wanted features for nociceptor
            first_h, first_w, init_freq, sust_freq, n_peak, pattern = analyse(sol_n, stim)

            results.nociceptor.M_first_peak_h[j, i]      = first_h
            results.nociceptor.M_first_peak_w[j, i]      = first_w
            results.nociceptor.M_init_freq[j, i]         = init_freq
            results.nociceptor.M_sust_freq[j, i]         = sust_freq
            results.nociceptor.M_peak_count[j, i]        = n_peak
            results.nociceptor.M_pattern[j, i]           = pattern
        end

        if !isnothing(sol_pn)
            # Compute wanted features for projection neuron
            first_h, first_w, init_freq, sust_freq, n_peak, pattern = analyse(sol_pn, stim)

            results.projection_neuron.M_first_peak_h[j, i]      = first_h
            results.projection_neuron.M_first_peak_w[j, i]      = first_w
            results.projection_neuron.M_init_freq[j, i]         = init_freq
            results.projection_neuron.M_sust_freq[j, i]         = sust_freq
            results.projection_neuron.M_peak_count[j, i]        = n_peak
            results.projection_neuron.M_pattern[j, i]           = pattern
        end

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

function parameter_analyses(VEC_amp, f_1D::File1D)

    u0 = f_1D.u0
    duration = f_1D.duration
    VEC_p_model = f_1D.VEC_p_model
    VEC_label = f_1D.VEC_label
    
    results = analyse_result(VEC_amp, VEC_p_model, f_1D.with_nociceptor, f_1D.with_projection_neuron)
    for i in 1:length(VEC_p_model)
        fill_analyse_result(i, results, VEC_p_model, u0, VEC_label; duration = duration)
    end
    return results
end
