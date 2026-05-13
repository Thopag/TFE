
############################ PARAMETER SET TYPE ############################
folder = "DIV7"
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

    amp = 2.0                   # pA
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = duration - stim_on - 200.0         # ms

    inhib = 0.9
    shift = 1000.0
    param = get_param(amp; stim_on=stim_on, stim_length=stim_length,
        #C_lidocaine=shift,
        g_nav1p3 = 0.35,
        g_nav1p7 = 35.0,
        g_nav1p8 = 0.2,
        )

    u0 = get_u0()

    file_prefix = "$(folder)_$(amp)amp"

    print("--------------- Start Simulation ---------------\n")
    println("Parameter set type : $folder")
    println("I_ext : $amp pA")

    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), param)
    print("--------------- End Simulation ---------------\n")

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, dV_dt = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, param)
    peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
    t_spikes = t[peaks_idx]

    freq, pattern = global_pattern(t_spikes, n_peak, param.stim_on, param.stim_off; window_width=100)
    pred_pattern = Ploting.pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")

    # --- Plots --- #

    if with_plot
        # 400 1700
        xlimits = (stim_on-25, stim_on+150)
        plt_all = init_plot_all(; xlimits=xlimits)
        plot_all(plt_all, t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                                I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, param)

        # plt_traj = plot(V, dV_dt, color=:black, label="")
        # xlabel!(plt_traj, "Voltage (mV)")
        # ylabel!(plt_traj, "dV/dt (mV/s)")

        # plot!(plt_traj, ylim=(-90,170))
        # plot!(plt_traj, xlim=(-90,40))
        # # display(plt_traj)
        # savefig(plt_traj, "plots/single_simulation/$(file_prefix)_traj.pdf")

        #display(plt_all)
        savefig(plt_all, "plots/simulation/$(file_prefix)_all.png")
        #savefig(plt_all, "plots/simulation/$(file_prefix)_all.pdf")
    end
end

main()