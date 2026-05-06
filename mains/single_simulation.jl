
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    with_plot = true

    amp = 50.0                   # pA
    duration = 1700.0             # ms
    stim_on = 0.0               # ms
    stim_length = 1700.0          # ms

    inhib = 0.9
    shift = 0.0
    p = get_param(amp; stim_on=stim_on, stim_length=stim_length,
        #C_lidocaine=shift,
        #with_lido_shift=true,
        #with_inhibition=false,
        #g_nav1p7=35.0*(1.0-inhib),
        #g_nav1p8=30.0*(1.0-inhib)
        #g_nav1p7=10.5,g_nav1p3=1.0
        )

    u0 = get_u0()

    print("--------------- Start Simulation ---------------\n")
    println("Parameter set type : $folder")
    println("I_ext : $amp pA")

    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), p)
    print("--------------- End Simulation ---------------\n")

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, dV_dt = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)
    peaks_idx, n_peak, w_peaks = get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
    t_spikes = t[peaks_idx]

    freq, pattern = global_pattern(t_spikes, n_peak, p.stim_on, p.stim_off; window_width=100)
    pred_pattern = Ploting.pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")

    # --- Plots --- #

    # 400 1700
    xlimits = (400, 1700)

    if with_plot
        plt_all = plot_all(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                                I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, p
                                    ; xlimits=xlimits)

        plt_traj = plot(V, dV_dt, color=:black, label="")
        xlabel!(plt_traj, "Voltage (mV)")
        ylabel!(plt_traj, "dV/dt (mV/s)")

        plot!(plt_traj, ylim=(-90,170))
        plot!(plt_traj, xlim=(-90,40))

        display(plt_all)
        # display(plt_traj)

        savefig(plt_all, "plots/single_simulation/plot_all.png")
        savefig(plt_traj, "plots/single_simulation/plot_traj.svg")
    end

    # p_freq = scatter(t_spikes[1:end-1], freqs)
    # display(p_freq)
end

main()