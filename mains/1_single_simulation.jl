
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    nociceptor_parameter = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    nociceptor_parameter = DIV7_parameter
    get_u0 = DIV7_u0
end

function main(;extra=0.0)

    with_plot = true

    amp = 20.0                                      # pA
    duration = 1700.0                               # ms
    stim_on = 500.0                                 # ms
    stim_length = duration - stim_on - 200.0        # ms

    p_lido = lidocaine_parameter()
    p_noci = nociceptor_parameter()
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length)
    p_model = model_parameter(p_stim, p_noci; lidocaine=p_lido)

    file_prefix = "$(folder)"

    u0 = get_u0()
 
    print("------------------------------\n")
    println("Parameter set type : $folder")
    println("I_ext : $amp pA")

    sol = simulation(u0, (0.0, duration), p_model)
    t = sol.t
    V = sol.V

    current = give_currents(sol, p_model)
    peaks_idx, n_peak, w_peaks = TFE.get_peaks(t, V;  min_h=-5.0, min_proms=10.0)

    t_spikes = t[peaks_idx]

    freqs = TFE.instant_freqs(t_spikes, n_peak)

    freq, pattern = global_pattern(t_spikes, n_peak, p_stim.off)
    pred_pattern = Ploting.pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")

    # --- Plots --- #

    if with_plot
        #xlimits = (stim_on-25, stim_on+150)
        #xlimits = (stim_on-50, stim_on+stim_length+50)
        xlimits = (0.0, stim_on+stim_length+50)
        plt = plot_single_simulation(sol, current, p_model, t_spikes; xlimits=xlimits)

        #display(plt)
        savefig(plt, "plots/simulation/$(file_prefix)_all.png")
        savefig(plt, "plots/simulation/$(file_prefix)_all.pdf")

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