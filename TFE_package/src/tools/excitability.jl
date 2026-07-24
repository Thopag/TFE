export get_excitability

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


function find_rheobase(amps, p_model, u0, duration)

    stim = p_model.stimulation

    L = length(amps)
    for (k,amp) in enumerate(amps)
        print("\rProgress: $(round(((k-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #
        i_stim = change_stimulation_amp(amp, stim)
        i_p_model = from_model_parameter(p_model; stimulation=i_stim)
        sol_n, _, _ = nociceptor_simulation(u0, (0.0, duration), i_p_model)

        # -- Get predicted pattern -- #
        _, pattern = get_excitability(sol_n.t_spikes, i_stim.off)
        if (pattern >= 1)
            return amp
        end
    end
    print("\r")
    return nothing
end