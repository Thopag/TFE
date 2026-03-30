include("DIV0/params.jl")
include("DIV7/params.jl")

folder = "DIV7"

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    amp = 20                    # pA
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = 1000.0          # ms

    p = param = get_param(amp, stim_on, stim_length;
        with_noise = false,
        C_lidocaine=0.0,
        g_nav1p8=10000.0,
        with_original=false,
        #with_lido_shift=true,
        #with_inhibition=false,
        )

    u0 = get_u0()

    print("folder: $folder with amp = $amp pA\n")

    print("--------------- Start Simulation ---------------\n")
    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise,n_test,l_test = ODE.simulation(u0, (0.0, duration), p)
    print("--------------- End Simulation ---------------\n")

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)
    peaks_idx, n_peak = get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
    t_spikes = t[peaks_idx]

    freq, first_count, pattern = global_pattern(t_spikes, n_peak, p.stim_on, p.stim_off; window_width=100)
    println(pattern)
    pred_pattern = Ploting.label_list[pattern+1]
    println("Predicted pattern : $pred_pattern")

    # --- Plots --- #

    # 400 1700
    xlimits = (400, 750)

    # p_volt = empty_voltage_plot()
    # plot_voltage(t, V, amp, peaks_idx; given_p=p_volt, save=false, with_peak=true)
    # vline!(p_volt, stim_on:100:stim_off, color=:red, linestyle=:dash, label="")
    # display(p_volt)

    plt_all = plot_all(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                            I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise
                                ; xlimits=xlimits)
    display(plt_all)
    savefig(plt_all, "plots/plot_all.pdf")

    # p_freq = scatter(t_spikes[1:end-1], freqs)
    # display(p_freq)
    # p_windows = scatter(1:length(counts), counts)
    # display(p_windows)
end

main()