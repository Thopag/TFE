
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

    amps = 15:5:25.0

    # -------- Set up -------- #

    changing_params = amps
    changing_param_name = "amp (pA)"
    u0 = get_u0()

    # -------- Timing set up -------- #

    duration = 1700.0               # ms
    stim_on = 500.0                 # ms
    stim_length = 1000.0            # ms

    # -------- Plot Set up -------- #

    xlimits = (stim_on-25, stim_on+150)
    plt_all = init_plot_all(; xlimits=xlimits)

    L = length(changing_params)
    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("")

    colors = theme_palette(:default).colors

    for (i,changing_param) in enumerate(changing_params)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")
        amp = changing_param
        param = get_param(amp; stim_on=stim_on, stim_length=stim_length,
                #C_lidocaine=shift,
                )

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), param)

        I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, dV_dt = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, param)
        peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
        t_spikes = t[peaks_idx]

        several_plot_all(plt_all, colors[i], t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                                I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, param; label="$changing_param")

    end
    println("\r################ End Looping ################ ")

    #display(plt_all)
    savefig(plt_all, "plots/multi_simulation/all.png")
    savefig(plt_all, "plots/multi_simulation/all.pdf")
end

main()