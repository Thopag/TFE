export Model_Parameters, give_currents, steady_state_currents, global_pattern, parameter_analyse, make_bifurcation

# --------------------------- Parameters struct --------------------------- #

struct Model_Parameters{T}
    amp::T
    CellArea::T
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
    C_lidocaine::T
    with_original::Bool
end

function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

# --------------------------- Get Currents --------------------------- #

function give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,p)

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

    Iext = p.I0 .+ pulse.(t, p.stim_on, p.stim_off) .* p.Excitation

    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IKdr .- IKm .- ILeak .- IAHP) ./ p.C

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt
    
end

function steady_state_currents(p, V)

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

    C_lido = p.C_lidocaine

    m3 = m_inf_1_3.(V; C_lido=C_lido)
    h3 = h_inf_1_3.(V; C_lido=C_lido)

    m7 = m_inf_1_7.(V; C_lido=C_lido)
    h7 = h_inf_1_7.(V; C_lido=C_lido)

    m8 = m_inf_1_8.(V; C_lido=C_lido)
    h8 = h_inf_1_8.(V; C_lido=C_lido)

    nm = n_inf_K_M.(V)

    ndr = n_inf_K_dr.(V)
    ldr = l_inf_K_dr.(V)

    z_AHP = z_AHP_inf.(V)

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)
    Iext = p.I0 .+ p.Excitation

    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IKdr .- IKm .- ILeak .- IAHP) ./ p.C

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt
end

# --------------------------- Pattern Detection --------------------------- #

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

function window_count(t_spikes, on, off; window_width=100)

    edges = on:window_width:off
    lowers = edges[1:end-1]
    uppers = edges[2:end]
    counts = count.((x -> (l <= x < u) for (l, u) in zip(lowers, uppers)), Ref(t_spikes))

    return counts
end

function global_pattern(t_spikes, n_peak, begin_stim, end_stim; window_width=100)
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

    #counts =  window_count(t_spikes, begin_stim, end_stim; window_width=window_width)
    #first_count = 404 #counts[1]
    
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

function parameter_analyse(param_sets, u0; duration = 1700.0)

    L = length(param_sets)
    VEC_peak_count = Vector{Int}(undef, L)
    VEC_freq = Vector{Float32}(undef, L)
    VEC_pattern = Vector{Int}(undef, L)
    VEC_first_peak_h = Vector{Float32}(undef, L)
    VEC_first_peak_w = Vector{Float32}(undef, L)

    for (i,param_set) in enumerate(param_sets)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise = simulation(u0, (0.0, duration), param_set)

        # ---- Peak Detection ---- #

        # Peak detection
        peaks_idx, peak_count, w_peaks = get_peaks(t, V;  min_h=-5.0, min_proms=10)
        t_spikes = t[peaks_idx]

        # Remove wrong peak detection that appear before stimulation
        # Strangly happend with the configuration: DIV0 at 100 pA without Na current
        peaks_idx = peaks_idx[t_spikes .> param_set.stim_on]
        t_spikes = t_spikes[t_spikes .> param_set.stim_on]

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

        freq, pattern = global_pattern(t_spikes, peak_count, param_set.stim_on, param_set.stim_off)

        VEC_peak_count[i]   = peak_count
        VEC_freq[i]         = freq
        VEC_pattern[i]      = pattern
        VEC_first_peak_h[i] = first_peak_height
        VEC_first_peak_w[i] = first_peak_width
    end

    print("\r")

    return VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w
end

# --------------------------- Bifurcation --------------------------- #

function make_bifurcation(param_init, u0, lens_param, p_min, p_max)

    prob = BifurcationProblem(ODE_system_bifurcation, u0, param_init, lens_param, 
        record_from_solution = (x, p; k...) -> x[1])

    step_scaling = 100
    opts = ContinuationPar(
        p_min = p_min, 
        p_max = p_max,
        max_steps = 10000*step_scaling ,
        dsmin = 0.01/step_scaling , 
        ds = 0.1/step_scaling ,
        dsmax = 1/step_scaling ,
        detect_bifurcation = 3,
    )
    br = continuation(prob, PALC(), opts)
    return br
end