
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

function main(;extra=0.0)

    with_plot = true

    amp = 50.0                   # pA
    duration = 50000.0             # ms
    stim_on = 500.0               # ms
    stim_length = duration - stim_on - 200.0         # ms

    shift = 0.0
    inhib = 0.925
    param = get_param(amp; stim_on=stim_on, stim_length=stim_length,
        #C_lidocaine=shift,
        #g_nav1p8 = 30.0 * (1-inhib),
        g_nav1p3 = 0.0,
        g_nav1p7 = 60.0,
        g_nav1p8 = 0.2,
        )

    file_prefix = "$(folder)"#_$(amp)amp"

    u0 = get_u0()
    #u0[1: end-1] = [-50.2126247161288, 0.45933775981465164, 0.0485126079545434, 0.1694457999024514, 0.00826080421626194, 0.007958185816536244, 0.9283153023896267, 0.02809157585619739, 0.30161943643279443, 0.045541292337403824, 1.0124299845052346e-6]
    
    print("------------------------------\n")
    println("Parameter set type : $folder")
    println("I_ext : $amp pA")

    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), param)

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, dV_dt = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, param)
    peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)

    t_spikes = t[peaks_idx]

    freqs = TFE.instant_freqs(t_spikes, n_peak)

    freq, pattern = global_pattern(t_spikes, n_peak, param.stim_on, param.stim_off; window_width=100)
    pred_pattern = Ploting.pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")
    
    # --- Plots --- #

    if with_plot
        # xlimits = (stim_on-25, stim_on+150)
        xlimits = (stim_on-50, stim_on+stim_length+50)
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

    if n_peak > 1
        p_freq = plot(t_spikes[1:end-1], freqs, label="", marker=:circle, markersize=4, markerstrokecolor = :match, markerstrokewidth = 0.0)
    else
        p_freq = plot()
    end
    savefig(p_freq, "plots/simulation/$(file_prefix)_freqs.pdf")

    print("------------------------------\n")
end

# amps = 33.0:0.5:40.0
# for a in amps
#     main(; extra = a)
# end

main()