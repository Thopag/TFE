export single_simulation

function single_simulation(DIV, nociceptor_parameter, set_u0_noci, get_u0_noci, Ihold;)

    with_plot = true

    amp = 51.0                                      # pA
    duration = 1700.0                               # ms
    stim_on = 500.0                                 # ms
    stim_length = duration - stim_on - 200.0        # ms

    p_lido = lidocaine_parameter()
    p_noci = nociceptor_parameter()
    p_pn = projection_neuron_parameter()
    p_s = synapse_parameter()
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold)
    p_model = model_parameter(stimulation= p_stim, nociceptor=p_noci, projection_neuron=p_pn, synapse=p_s, lidocaine=p_lido)

    print("------------------------------\n")
    println("Parameter set type : $DIV")
    println("I_ext : $amp pA")

    file_prefix = "$(DIV)"
    file_prefix = "test"

    u0 = get_synapse_u0(set_u0_noci)

    #@time sol = nociceptor_simulation(u0, (0.0, duration), p_model)
    #@time sol = projection_neuron_simulation(u0, (0.0, duration), p_model)
    @time sol_n, sol_pn, sol_s = with_synapse_simulation(u0, (0.0, duration), p_model)

    sol = sol_n
    t_spikes = sol.t_spikes
    n_peak = length(t_spikes)

    freqs = instant_freqs(t_spikes)

    freq, pattern = get_excitability(t_spikes, p_stim.off)
    pred_pattern = pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")


    # --- Plots --- #

    if with_plot
        xlimits = (0.0, duration)
        plt = plot_single_simulation(sol_n, sol_pn, sol_s, p_model; xlimits=xlimits)

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
    return
end
