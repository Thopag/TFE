
struct AnalyseResults
    M_first_peak_h_w::Matrix{Tuple{Float32, Float32}}
    M_freq::Matrix{Float32}
    M_peak_count::Matrix{Int}
    M_pattern::Matrix{Int}
    M_limit_cycle_min_max::Matrix{Tuple{Float64, Float64}}
    VEC_rheobase::Vector{Union{Nothing,Float32}}
    VEC_p_model::Vector{ModelParameters}
    VEC_amp::Vector{Float64}
    VEC_label::Vector{String}
    parameter_label::String
end

# --- init --- #

function analyse_result(VEC_amp, VEC_p_model, VEC_label, parameter_label)
    n_row = length(VEC_amp)
    n_col = length(VEC_p_model)

    M_first_peak_h_w = Matrix{Tuple{Float64, Float64}}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)
    M_limit_cycle_min_max = Matrix{Tuple{Float64, Float64}}(undef, n_row, n_col)

    VEC_rheobase = Vector{Union{Nothing,Float32}}(undef, n_col)

    return AnalyseResults(M_first_peak_h_w, M_freq, M_peak_count, M_pattern, M_limit_cycle_min_max, VEC_rheobase, 
                                                    VEC_p_model, VEC_amp, VEC_label, parameter_label)
end

function analyse(p_model, u0; duration = 1700.0)

    stim = p_model.stimulation
    sol = nociceptor_simulation(u0, (0.0, duration), p_model)
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

function make_analyse(amps_p_model, u0; duration = 1700.0)

    L = length(amps_p_model)
    VEC_first_peak_h_w      = Vector{Tuple{Float32, Float32}}(undef, L)
    VEC_freq                = Vector{Float32}(undef, L)
    VEC_peak_count          = Vector{Int}(undef, L)
    VEC_pattern             = Vector{Int}(undef, L)
    VEC_limit_cycle_min_max = Vector{Tuple{Float64, Float64}}(undef, L)

    for (i,p_model) in enumerate(amps_p_model)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")
        first_h_w, freq, n_peak, pattern, min_max = analyse(p_model, u0; duration = duration)

        VEC_first_peak_h_w[i]       = first_h_w
        VEC_freq[i]                 = freq
        VEC_peak_count[i]           = n_peak
        VEC_pattern[i]              = pattern
        VEC_limit_cycle_min_max[i]  = min_max
    end

    print("\r")
    return VEC_first_peak_h_w, VEC_freq, VEC_peak_count, VEC_pattern, VEC_limit_cycle_min_max
end

function fill_analyse_result(i::Int, results::AnalyseResults, u0; duration = 1700.0)

    L = length(results.VEC_label)
    println("$(results.VEC_label[i]) -- $(round(((i-1)/L*100), digits=2)) % is done")

    p_model = results.VEC_p_model[i]

    VEC_stim = map( (amp) -> change_stimulation_amp(amp, p_model.stimulation), results.VEC_amp)
    amps_p_model = map( (stim) -> from_model_parameter(p_model; stimulation=stim), VEC_stim)

    VEC_first_peak_h_w, VEC_freq, VEC_peak_count, VEC_pattern, VEC_limit_cycle_min_max = make_analyse(amps_p_model, u0; duration = duration)

    rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
    results.VEC_rheobase[i] = results.VEC_amp[rheobase_idx]

    results.M_first_peak_h_w[:, i] = VEC_first_peak_h_w
    results.M_freq[:, i] = VEC_freq
    results.M_peak_count[:, i] = VEC_peak_count
    results.M_pattern[:, i] = VEC_pattern
    results.M_limit_cycle_min_max[:, i] = VEC_limit_cycle_min_max

    return
end

function parameter_analyses(VEC_amp, VEC_p_model, duration, u0, VEC_label, parameter_label)

    results = analyse_result(VEC_amp, VEC_p_model, VEC_label, parameter_label)
    for i in 1:length(VEC_p_model)
        fill_analyse_result(i, results, u0; duration = duration)
    end
    return results
end
