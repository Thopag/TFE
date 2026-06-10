export global_pattern, find_rheobase, parameter_analyse, init_parameter_analyses, iteration_parameter_analyses, end_parameter_analyses

function get_peaks(t, x; min_h=-5.0, min_proms=10.0, max_w=Inf)

    peaks = findmaxima(x)
    if length(peaks[1]) == 0
        return peaks[1], 0, []
    end
    r = peaks[1]
    peaks = peakheights(peaks; min=min_h)
    if length(peaks[1]) == 0
        return r, 0, []
    end
    r = peaks[1]
    peaks = peakproms(peaks; min=min_proms)
    if length(peaks) == 0
        return r, 0, []
    end
    peaks_idx, h, data, proms, w, edges = peakwidths(peaks)

    right = last.(edges)
    left = first.(edges)
    right = Int.(trunc.(right))
    left = Int.(trunc.(left))

    w = t[right] .- t[left]
    peaks_idx = peaks_idx[w .< max_w]

    w_peaks = w[w .< max_w]

    return peaks_idx, length(peaks_idx), w_peaks
end

function instant_freqs(t_spikes, n_peak)

    #If there is only 0 or 1 spike, we got a null frequence
    if n_peak <= 1
        return [0]
    end
    delta_t = diff(t_spikes)
    # 1000 -> to go from ms to s
    freqs =  1000 ./ delta_t
    return freqs
end


function global_pattern(t_spikes, n_peak, end_stim)
    """
    Value of pattern :
    0 : No spike
    1 : Single spike 
    2 : Two spikes 
    3 : Transient
    4 : Spikling
    """
    freqs = instant_freqs(t_spikes, n_peak)
    f_global = mean(freqs)

    
    if n_peak == 0
        pattern = 0
        return f_global, pattern
    elseif n_peak == 1
        pattern = 1
        return f_global, pattern
    elseif n_peak == 2
        pattern = 2
        return f_global, pattern
    end

    # Do not verify if length freq > 0
    # If pass the previous "if", it is supposed to be OK
    last_delta_t = 1000 / freqs[end]
    if (t_spikes[end] + last_delta_t*1.2) > end_stim
        pattern = 4
    else
        pattern = 3
    end
    
    return f_global, pattern
end

function find_rheobase(p_noci, p_lido, amps, u0; duration = 1700.0)

    is_finded = false
    rheobase = NaN32
    spiking = NaN32
    L = length(amps)
    for (i,amp) in enumerate(amps)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")
        # -- Make Simulation -- #

        p_stim = stimulation_parameter(amp)
        p_model = model_parameter(p_stim, p_noci; lidocaine=p_lido)
        sol = simulation(u0, (0.0, duration), p_model)
        t = sol.t
        V = sol.V

        # ---- Peak Detection ---- #

        # Peak detection
        peaks_idx, peak_count, _ = get_peaks(t, V;  min_h=-5.0, min_proms=10)
        t_spikes = t[peaks_idx]

        peaks_idx = peaks_idx[t_spikes .> p_stim.on]
        t_spikes = t_spikes[t_spikes .> p_stim.on]

        if peak_count > 0
            peak_count = length(peaks_idx)
        end

        _, pattern = global_pattern(t_spikes, peak_count, p_stim.off)

        if (pattern >= 1) && (!is_finded)
            print("\r")
            rheobase = amp
            is_finded = true
        end

        if (pattern == 4)
            print("\r")
            spiking = amp
            return rheobase, spiking
        end
    end

    print("\r")
    return rheobase, spiking
end

# ----- small function used in bifurcation limit cycle ----- #

function get_pattern(sol, stim)
    t = sol.t
    V = sol.V
    peaks_idx, n_peak, w_peaks = get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
    t_spikes = t[peaks_idx]
    _, pattern = global_pattern(t_spikes, n_peak, stim.off)
    return pattern
end

# -------------------------- parameter_analyse -------------------------- #

function parameter_analyse(VEC_p_model, u0; duration = 1700.0)

    L = length(VEC_p_model)
    VEC_peak_count = Vector{Int}(undef, L)
    VEC_freq = Vector{Float32}(undef, L)
    VEC_pattern = Vector{Int}(undef, L)
    VEC_first_peak_h = Vector{Float32}(undef, L)
    VEC_first_peak_w = Vector{Float32}(undef, L)

    for (i,p_model) in enumerate(VEC_p_model)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #
        stim = p_model.stimulation

        sol = simulation(u0, (0.0, duration), p_model)
        t = sol.t
        V = sol.V

        # ---- Peak Detection ---- #

        # Peak detection
        peaks_idx, peak_count, w_peaks = get_peaks(t, V;  min_h=-5.0, min_proms=10)
        t_spikes = t[peaks_idx]

        # Remove wrong peak detection that appear before stimulation
        # Strangly happend with the configuration: DIV0 at 100 pA without Na current
        peaks_idx = peaks_idx[t_spikes .> stim.on]
        t_spikes = t_spikes[t_spikes .> stim.on]

        if peak_count > 0
            peak_count = length(peaks_idx)
        end
        
        # Default values
        first_peak_height = -65.0
        first_peak_width = 0.0

        # "length(peaks_idx)" is use instead of "peak_count",
        # because peaks_idx can contain peaks even if peak_count==0
        if length(peaks_idx) > 0
            first_peak_height = V[peaks_idx[1]]
        end

        # if not, w_peaks = [] (see get_peaks() function)
        if peak_count > 0
            first_peak_width = w_peaks[1]
        end

        freq, pattern = global_pattern(t_spikes, peak_count, stim.off)

        VEC_peak_count[i]   = peak_count
        VEC_freq[i]         = freq
        VEC_pattern[i]      = pattern
        VEC_first_peak_h[i] = first_peak_height
        VEC_first_peak_w[i] = first_peak_width
    end

    print("\r")
    return VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w
end

function init_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter)
    n_row = length(VEC_intra_parameter)
    n_col = length(VEC_inter_parameter)

    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)
    M_first_peak_h = Matrix{Float32}(undef, n_row, n_col)
    M_first_peak_w = Matrix{Float32}(undef, n_row, n_col)

    inter_with_rheobase = Vector{String}()
    rheobases = Vector{Float32}()

    return M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
end

function iteration_parameter_analyses(i, params, u0, label, VEC_intra_parameter,
                                M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)

    VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w = parameter_analyse(params, u0;)

    # Get the first parameter that has a spike
    # This is mainly used when the intra_parameter is "Amp"
    rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
    if !isnothing(rheobase_idx)
        push!(inter_with_rheobase, label)
        push!(rheobases, VEC_intra_parameter[rheobase_idx])
    end

    M_peak_count[:, i] = VEC_peak_count
    M_freq[:, i] = VEC_freq
    M_pattern[:, i] = VEC_pattern
    M_first_peak_h[:, i] = VEC_first_peak_h
    M_first_peak_w[:, i] = VEC_first_peak_w 
end

function end_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)
    
    return plot_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)
end