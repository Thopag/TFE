export get_firing_pattern, find_rheobase, find_spiking

function get_first_peak_height_and_width(t, x; min_h=-5.0, min_proms=10.0, max_w=Inf)

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
        return NaN32, NaN32
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

function get_init_and_sustaine_freq(t_spikes, freqs, t_frontier)

    if !isempty(t_spikes)
        if length(t_spikes) > 1
            t_spikes_ = t_spikes[1:end-1]
        else
            t_spikes_ = t_spikes
        end
    else # If no spike
        return 0.0, 0.0
    end

    init_freqs = freqs[t_spikes_ .<= t_frontier]
    if isempty(init_freqs)
        init_freqs = [0.0]
    end

    sustaine_freqs = freqs[t_spikes_ .> t_frontier]
    if isempty(sustaine_freqs)
        sustaine_freqs = [0.0]
    end
    
    return mean(init_freqs), mean(sustaine_freqs)
end

function get_firing_pattern(t_spikes, end_stim)
    """
    Value of excitability :
    0 : No spike
    1 : Single spike 
    2 : Transient
    3 : Spiking
    """
    t_frontier = 600
    freqs = instant_freqs(t_spikes)
    f_init, f_sust = get_init_and_sustaine_freq(t_spikes, freqs, t_frontier)

    n_peak = length(t_spikes)
    if n_peak == 0
        pattern = 0
        return f_init, f_sust, pattern
    elseif n_peak == 1
        pattern = 1
        return f_init, f_sust, pattern
    end

    # Do not verify if length freq > 0
    # If pass the previous "if", it is supposed to be OK
    last_delta_t = t_spikes[end]-t_spikes[end-1]
    if (t_spikes[end] + last_delta_t*1.2) > end_stim
        pattern = 3
    else
        pattern = 2
    end
    return f_init, f_sust, pattern
end

# --------- I rheobase ---------- #
# make the hypothesis that single spike 
# do not disappear with increased stimulation amplitude
# -> dichotomic research

function condition_dichotomic_search(arr, cond)
    L = length(arr)
    low = 1
    high = L
    while (low <= high)
        mid = low + div(high - low, 2)
        #println("low = $(low) - mid = $(mid) - high = $(high)")
        if cond(arr[mid])
            high = mid - 1
        else
            low = mid + 1
            if low >= L
                return nothing
            end
        end
    end
    return low
end

function is_single_spike(amp, p_model, u0, duration)

    stim = p_model.stimulation
    i_stim = change_stimulation_amp(amp, stim)
    i_p_model = from_model_parameter(p_model; stimulation=i_stim)
    sol_n, _, _ = nociceptor_simulation(u0, (0.0, duration), i_p_model)

    _, _, pattern = get_firing_pattern(sol_n.t_spikes, i_stim.off)
    if (pattern >= 1)
        return true
    else
        return false
    end
end

function find_rheobase(amps, p_model, u0, duration)

    cond(amp) = is_single_spike(amp, p_model, u0, duration)
    idx = condition_dichotomic_search(amps, cond)

    return idx
end

# --------- I spiking ---------- #

function is_spiking(amp, p_model, u0, duration)

    stim = p_model.stimulation
    i_stim = change_stimulation_amp(amp, stim)
    i_p_model = from_model_parameter(p_model; stimulation=i_stim)
    sol_n, _, _ = nociceptor_simulation(u0, (0.0, duration), i_p_model)

    _, _, pattern = get_firing_pattern(sol_n.t_spikes, i_stim.off)
    if (pattern == 3)
        return true
    else
        return false
    end
end

function find_spiking(amps, idx_rheo, p_model, u0, duration)

    if isnothing(idx_rheo)
        return nothing
    end

    cond(amp) = is_spiking(amp, p_model, u0, duration)

    L = length(amps)
    if cond(amps[div(L,4)])
        idx = condition_dichotomic_search(amps[1:div(L,4)], cond)
    elseif cond(amps[div(L,2)])
        idx = condition_dichotomic_search(amps[1:div(L,2)], cond)
    elseif cond(amps[L])
        idx = condition_dichotomic_search(amps, cond)
    else
        idx_jump = div(idx_rheo, 5)
        found = false
        idx = idx_rheo
        L = length(amps)
        while (idx <= L) && (!found)
            if cond(amps[idx])
                found = true
            else
                idx += idx_jump
            end
        end

        if !found
            idx = nothing
        end
    end

    return idx
end