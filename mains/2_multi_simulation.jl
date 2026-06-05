
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

    amps = [16.0, 16.0, 20.0]
    amps_cst = zeros(6) .+ 120

    amps = amps

    # -------- Timing set up -------- #

    duration = 1700.0                                   # ms
    stim_on = 500.0                                     # ms
    stim_length = duration - stim_on - 200.0            # ms

    # -------- Set up -------- #

    file_prefix = "$(folder)"

    p_lido = lidocaine_parameter(;)
    p_noci = nociceptor_parameter(;)
    VEC_stim = map( (amp) -> stimulation_parameter(amp; on=stim_on, length=stim_length), amps)

    VEC_p_model = map( (changing) -> model_parameter(changing, p_noci; lidocaine=p_lido), VEC_stim)


    labels = [L"%$ amp \: pA" for amp in amps]
    L = length(VEC_p_model)

    # -------- Plot Set up -------- #

    xlimits = (stim_on-25, stim_on+150)
    #xlimits = (stim_on-50, stim_on+stim_length+50)
    plt_all = init_plot_multi_simulation(; xlimits=xlimits)

    
    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("")

    colors = theme_palette(:default).colors
    for (i,(p_model,label)) in enumerate(zip(VEC_p_model, labels))
        #print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        sol = simulation(u0, (0.0, duration), p_model)
        t = sol.t
        V = sol.V

        current = give_currents(sol, p_model)
        peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)
        t_spikes = t[peaks_idx]

        plot_multi_simulation(plt_all, sol, current, p_model, t_spikes, colors[i]; label=label)

    end
    println("\r################ End Looping ################ ")

    #display(plt_all)
    savefig(plt_all, "plots/simulation/$(file_prefix)_several_all.png")
    savefig(plt_all, "plots/simulation/$(file_prefix)_several_all.pdf")
end

main()