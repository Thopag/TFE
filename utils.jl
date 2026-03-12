module Utils

using Peaks
using Statistics

export Parameters, give_currents, pulse, get_peaks, instant_freqs, global_freq, window_count, get_lidocaine_inhibition

# --------------------------- Parameters struct --------------------------- #

struct Parameters{T}
    I0::T
    stim_on::T
    stim_off::T
    Excitation::T
    C::T
    g_nav1p3::T
    g_nav1p7::T
    g_nav1p8::T
    E_Na::T
    g_Kdr::T
    g_Km::T
    g_AHP::T
    E_k::T
    g_Leak::T
    E_Leak::T
    sigma_noise::T
    mu_noise::T
    tau_noise::T
    with_noise::Bool
end

function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

function give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)

    g_nav1p3 = p.g_nav1p3
    g_nav1p7 = p.g_nav1p7
    g_nav1p8 = p.g_nav1p8
    E_Na = p.E_Na

    g_Kdr = p.g_Kdr
    g_Km = p.g_Km
    g_AHP = p.g_AHP
    E_k = p.E_k

    g_Leak = p.g_Leak
    E_Leak = p.E_Leak

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)

    I_ext = p.I0 .+ pulse.(t, p.stim_on, p.stim_off) .* p.Excitation

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, I_ext
    
end

function get_peaks(t, x; min_h=-25, min_proms=0, max_w=Inf)

    peaks = findmaxima(x)
    if length(peaks[1]) == 0
        return peaks[1], 0
    end
    peaks = peakheights(peaks; min=min_h)
    if length(peaks[1]) == 0
        return peaks[1], 0
    end
    peaks = peakproms(peaks; min=min_proms)
    if length(peaks) == 0
        return peaks[1], 0
    end

    peaks_idx, h, data, proms, w, edges = peakwidths(peaks)

    right = last.(edges)
    left = first.(edges)
    right = Int.(trunc.(right))
    left = Int.(trunc.(left))

    w = t[right] .- t[left]
    peaks_idx = peaks_idx[w .< max_w]

    return peaks_idx, length(peaks_idx)
end

function instant_freqs(t_spikes)

    #If there is only 0 or 1 spike, we got a null frequence
    if length(t_spikes) <= 1
        return [0]
    end
    delta_t = diff(t_spikes)
    # 1000 -> to go from ms to s
    freqs =  1000 ./ delta_t
    return freqs
end

function global_freq(t_spikes, end_stim)
    freqs = instant_freqs(t_spikes)

    f_global = mean(freqs)
    if f_global > 0
        last_delta_t = 1000 / freqs[end]
        if (t_spikes[end] + last_delta_t*1.2) > end_stim
            is_hyperexcitable = 1
        else
            is_hyperexcitable = 0
        end
    else
        return f_global, 0
    end
    
    return f_global, is_hyperexcitable
end

function window_count(t_spikes, on, off; window_width=100)

    edges = on:window_width:off
    lowers = edges[1:end-1]
    uppers = edges[2:end]

    counts = count.((x -> (l <= x < u) for (l, u) in zip(lowers, uppers)), Ref(t_spikes))
    first_count = counts[1]#mean(counts)

    return counts, first_count
end

hill(D, f_max, IC50, h, y0) = y0 + (f_max * D^h) / (IC50^h + D^h)

lidocain_1_7_channel(D) = hill(D, 1.0079, 477.1, 1.31, 1.52 / 100)
lidocain_1_8_channel(D) = hill(D, 0.9698, 118.31, 1.06, 4.78 / 100)

# which of the 2 ?
lidocain_1_3_inact_inib(D) = hill(D, 0.949, 284, 0.48, 0)
lidocain_1_3_resting_inib(D) = hill(D, 0.997, 1462, 1.35, 0)

function get_lidocaine_inhibition(C)
    # C in µM
    remaining_1_3 = 1.0 - lidocain_1_3_inact_inib(C) # which 1.3 ?
    remaining_1_7 = 1.0 - lidocain_1_7_channel(C)
    remaining_1_8 = 1.0 - lidocain_1_8_channel(C)

    return remaining_1_3, remaining_1_7, remaining_1_8
end


end