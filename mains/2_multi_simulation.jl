
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

    u0 = get_u0()

    amps_i_1_8 = [12.0, 12.0, 12.0, 12.0, 12.0, 12.0]
    amps_i_1_3 = [12.0, 13.0, 15.0, 17.0, 20.0, 23.0,]
    amps_i_1_7 = [12.0, 13.0, 14.0, 17.0, 27.0, 180.0]

    amps_cst = zeros(6) .+ 210.0

    amps = amps_cst

    VEC_g_nav1p7 = [3.0, 0.0, 0.0]
    VEC_inhib = [0.0, 0.9]
    VEC_shift = [0.0, 3.0]

    VEC_inter_param = VEC_shift

    # -------- Set up -------- #

    file_prefix = "$(folder)"

    params = map( (amp, inter_param) -> get_param(amp;
                    C_lidocaine = inter_param,
                    # g_nav1p3 = 0.35,
                    # g_nav1p7 = 35.0,
                    # g_nav1p8 = 30.0 * (1-inter_param) ,
                    )
                , amps, VEC_inter_param)

    labels = [L"shift_{act1.8} = %$inter_param - %$amp pA" for (amp, inter_param) in zip(amps, VEC_inter_param)]
    L = length(params)

    # -------- Timing set up -------- #

    duration = 1700.0               # ms
    stim_on = 500.0                 # ms
    stim_length = 1000.0            # ms

    # -------- Plot Set up -------- #

    #xlimits = (stim_on-25, stim_on+150)
    xlimits = (stim_on-50, stim_on+stim_length+50)
    plt_all = init_several_plot_all(; xlimits=xlimits)

    
    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("")

    colors = theme_palette(:default).colors

    for (i,(param,label)) in enumerate(zip(params, labels))
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        amp = param.amp
        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), param)

        I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, dV_dt = give_currents(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, param)
        peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
        t_spikes = t[peaks_idx]

        several_plot_all(plt_all, colors[i], t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                                I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, param; label=label)

    end
    println("\r################ End Looping ################ ")

    #display(plt_all)
    savefig(plt_all, "plots/simulation/$(file_prefix)_several_all.png")
    savefig(plt_all, "plots/simulation/$(file_prefix)_several_all.pdf")
end

main()