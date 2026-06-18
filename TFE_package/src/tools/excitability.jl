export get_excitability, find_rheobase, parameter_analyses

function get_first_peak_height_and_width(t, x; min_h=-70.0, min_proms=10.0, max_w=Inf)

    peaks = findmaxima(x)
    peaks = peakheights(peaks; min=min_h)
    peaks = peakproms(peaks; min=min_proms)
    peaks_idx, h, data, proms, w, edges = peakwidths(peaks)

    # edges is a vector of tuple (start, end)
    right = last.(edges)
    left = first.(edges)
    right = Int.(trunc.(right))
    left = Int.(trunc.(left))
    w = t[right] .- t[left]
    peaks_idx = peaks_idx[w .< max_w]

    if length(peaks_idx) == 0
        return nothing, nothing
    end
    w_peak = w[w .< max_w]
    h_peak = h[w .< max_w]
    return h_peak[1], w_peak[1]
end

function instant_freqs(t_spikes)

    n_peak = length(t_spikes)
    #If there is only 0 or 1 spike, we got a null frequence
    if n_peak <= 1
        return [0]
    end
    delta_t = diff(t_spikes)
    # 1000 -> to go from ms to s
    freqs =  1000 ./ delta_t
    return freqs
end


function get_excitability(t_spikes, end_stim)
    """
    Value of excitability :
    0 : No spike
    1 : Single spike 
    2 : Two spikes 
    3 : Transient
    4 : Spikling
    """
    freqs = instant_freqs(t_spikes)
    f_mean = mean(freqs)

    n_peak = length(t_spikes)
    if n_peak == 0
        pattern = 0
        return f_mean, pattern
    elseif n_peak == 1
        pattern = 1
        return f_mean, pattern
    elseif n_peak == 2
        pattern = 2
        return f_mean, pattern
    end

    # Do not verify if length freq > 0
    # If pass the previous "if", it is supposed to be OK
    last_delta_t = t_spikes[end]-t_spikes[end-1]
    if (t_spikes[end] + last_delta_t*1.2) > end_stim
        pattern = 4
    else
        pattern = 3
    end
    return f_mean, pattern
end

function find_rheobase(amps, p_model, stim, u0; duration = 1700.0)

    is_finded = false
    rheobase = NaN32
    spiking = NaN32
    L = length(amps)
    for (i,amp) in enumerate(amps)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #
        i_stim = change_stimulation_amp(amp, stim)
        i_p_model = from_model_parameter(p_model; stimulation=i_stim)
        sol = nociceptor_simulation(u0, (0.0, duration), i_p_model)

        # -- Get predicted pattern -- #
        _, pattern = get_excitability(sol.t_spikes, i_stim.off)


        # Check if there is at least one spike
        if (pattern >= 1) && (!is_finded)
            print("\r")
            rheobase = amp
            is_finded = true
        end

        # Check if there is spiking
        if (pattern == 4)
            print("\r")
            spiking = amp
            return rheobase, spiking
        end
    end

    print("\r")
    return rheobase, spiking
end

# -------------------------- parameter_analyse -------------------------- #

struct AnalyseResults
    M_first_peak_h::Matrix{Union{Nothing,Float32}}
    M_first_peak_w::Matrix{Union{Nothing,Float32}}
    M_freq::Matrix{Float32}
    M_peak_count::Matrix{Int}
    M_pattern::Matrix{Int}
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

    M_first_peak_h = Matrix{Union{Nothing,Float32}}(undef, n_row, n_col)
    M_first_peak_w = Matrix{Union{Nothing,Float32}}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)

    VEC_rheobase = Vector{Union{Nothing,Float32}}(undef, n_row)

    return AnalyseResults(M_first_peak_h, M_first_peak_w, M_freq, M_peak_count, M_pattern, VEC_rheobase, 
                                                    VEC_p_model, VEC_amp, VEC_label, parameter_label)
end

function analyse(p_model, u0; duration = 1700.0)

    stim = p_model.stimulation
    sol = nociceptor_simulation(u0, (0.0, duration), p_model)

    first_h, first_w = get_first_peak_height_and_width(sol.t, sol.V)
    freq, pattern = get_excitability(sol.t_spikes, stim.off)
    n_peak = length(sol.t_spikes)

    return first_h, first_w, freq, n_peak, pattern
end

function make_analyse(amps_p_model, u0; duration = 1700.0)

    L = length(amps_p_model)
    VEC_peak_count = Vector{Int}(undef, L)
    VEC_freq = Vector{Float32}(undef, L)
    VEC_pattern = Vector{Int}(undef, L)
    VEC_first_peak_h = Vector{Union{Nothing,Float32}}(undef, L)
    VEC_first_peak_w = Vector{Union{Nothing,Float32}}(undef, L)

    for (i,p_model) in enumerate(amps_p_model)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")
        first_h, first_w, freq, n_peak, pattern = analyse(p_model, u0; duration = duration)

        VEC_first_peak_h[i] = first_h
        VEC_first_peak_w[i] = first_w
        VEC_freq[i]         = freq
        VEC_peak_count[i]   = n_peak
        VEC_pattern[i]      = pattern
    end

    print("\r")
    return VEC_first_peak_h, VEC_first_peak_w, VEC_freq, VEC_peak_count, VEC_pattern
end

function fill_analyse_result(i::Int, results::AnalyseResults, u0; duration = 1700.0)

    L = length(results.VEC_label)
    println("$(results.VEC_label[i]) -- $(round(((i-1)/L*100), digits=2)) % is done")

    p_model = results.VEC_p_model[i]

    VEC_stim = map( (amp) -> change_stimulation_amp(amp, p_model.stimulation), results.VEC_amp)
    amps_p_model = map( (stim) -> from_model_parameter(p_model; stimulation=stim), VEC_stim)

    VEC_first_peak_h, VEC_first_peak_w, VEC_freq, VEC_peak_count, VEC_pattern = make_analyse(amps_p_model, u0; duration = duration)

    rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
    results.VEC_rheobase[i] = results.VEC_amp[rheobase_idx]

    results.M_first_peak_h[:, i] = VEC_first_peak_h
    results.M_first_peak_w[:, i] = VEC_first_peak_w 
    results.M_freq[:, i] = VEC_freq
    results.M_peak_count[:, i] = VEC_peak_count
    results.M_pattern[:, i] = VEC_pattern
    return
end

function parameter_analyses(VEC_amp, VEC_p_model, duration, u0, VEC_label, parameter_label)

    results = analyse_result(VEC_amp, VEC_p_model, VEC_label, parameter_label)
    for i in 1:length(VEC_p_model)
        fill_analyse_result(i, results, u0; duration = duration)
    end

    return results
end
