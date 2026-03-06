include("DIV0/params.jl")
include("DIV7/params.jl")

folder = "DIV7"

if folder == "DIV0"
    launch_simulation = ODE_DIV0.simulation
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    launch_simulation = ODE_DIV7.simulation
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function parameter_analyses()

    println("------ Start parameter analyses ------")
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = 1000.0          # ms
    end_stim = stim_on + stim_length
    u0 = get_u0()

    params = Vector{Parameters}()
    amps = 0:1:120
    for amp in amps
        param = get_param(amp, stim_on, stim_length;
        with_noise = true

        # ,g_nav1p8 = 4.0 # PHARMACOLOGY DIV0
        # ,g_nav1p7 = 40.0 # dynamic clamp DIV0

        ,g_nav1p7 = 10.5  # PHARMACOLOGY DIV7
        ,g_nav1p8 = 40.0  # dynamic clamp DIV7
        )
        push!(params, param)
    end

    p_volt = empty_voltage_plot()
    L = length(params)
    peaks_count = Vector{Int}()
    freqs = Vector{Float32}()
    hyperexct_vec = Vector{Int}()

    for ((i,param), amp) in zip(enumerate(params), amps)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), param)
        # plot!(p_volt, t, V, label=L"%$amp pA", alpha= 1)

        peaks_idx, n_peak = get_peaks(t, V;  min_h=-30)
        t_spikes = t[peaks_idx]
        freq, is_hyperexct = global_freq(t_spikes, end_stim)

        push!(peaks_count, n_peak)
        push!(freqs, freq)
        push!(hyperexct_vec, is_hyperexct)
    end
    println("\n------ Plots ------")

    x = amps
    hyperexct_colors = [h == 1 ? :red : :blue for h in hyperexct_vec]

    p_peaks = plot(x, peaks_count, xlabel="amp (pA)", ylabel= "Peaks count (-)", legend=false, color=:black, title="$folder peaks count")
    scatter!(p_peaks, x, peaks_count, color=hyperexct_colors, markersize=3)

    p_freqs = plot(x, freqs, xlabel="amp (pA)", ylabel= "Frequence (Hz)", legend=false, color=:black, title="$folder FI curve")
    scatter!(p_freqs, x, freqs, color=hyperexct_colors, markersize=3)

    plot!(p_volt, title="$folder samples")

    display(p_peaks)
    display(p_freqs)
    display(p_volt)

    savefig(p_peaks, "plots/$folder-peaks-curve.pdf")
    savefig(p_freqs, "plots/$folder-F-I-curve.pdf")
    savefig(p_volt, "plots/$folder-V_AMP.pdf")

    println("------ End parameter analyses ------")
end

function main_default()

    amp = 15*3                    # pA
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = 1000.0          # ms
    end_stim = stim_on + stim_length

    p = param = get_param(amp, stim_on, stim_length;
        with_noise = true

        # ,g_nav1p8 = 4.0 # PHARMACOLOGY DIV0
        # ,g_nav1p7 = 40.0 # dynamic clamp DIV0

        ,g_nav1p7 = 10.5  # PHARMACOLOGY DIV7
        ,g_nav1p8 = 40.0  # dynamic clamp DIV7
        )

    u0 = get_u0()

    print("folder: $folder with amp = $amp pA\n")

    print("--------------- Start Simulation ---------------\n")
    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), p)
    print("--------------- End Simulation ---------------\n")

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak = give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)
    peaks_idx, n_peak = get_peaks(t, V;  min_h=-25)
    t_spikes = t[peaks_idx]

    freqs = instant_freqs(t_spikes)
    freq, is_hyperexct = global_freq(t_spikes, end_stim)
    print(freq)

    # --- Plots --- #

    # 400 1700
    # 545 565
    xlimits = (500, 600)

    p_volt = empty_voltage_plot()
    plot_voltage(t, V, amp, peaks_idx; given_p=p_volt, save=false, with_peak=true)

    # plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp; xlimits=xlimits)
    # plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp; xlimits=xlimits)
    # plot_all_currents(t, V, I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, amp; xlimits=xlimits)
    # plot_test(t, V, ndr, ldr, n_test, l_test, amp)
    # plot_availability_voltage(t, V, m7, h7, m8, h8)

    # p_freq = scatter(t_spikes[1:end-1], freqs)
    # display(p_freq)
end

#main_default()
parameter_analyses()