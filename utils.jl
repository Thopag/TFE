module Utils

using Peaks

export Parameters, give_currents, get_peaks

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

function give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)

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

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak
    
end

function get_peaks(t, x; min_h=-60, min_proms=5, max_w=15)

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

end