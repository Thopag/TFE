export make_simulations

function used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)

    simulation_function = choose_simulation_function(with_nociceptor, with_projection_neuron)
    @time sol_n, sol_pn, sol_s = simulation_function(u0, (0.0, duration), p_model)
    return sol_n, sol_pn, sol_s
end

function plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, i; color = nothing, label = nothing)

    # Check if multi or single simulation
    if !isnothing(color) && !isnothing(label)
        plot!(plt[1], [], [], color=color, label=label)
    end

    # --------------------- NOCICEPTOR --------------------- #
    if !isnothing(sol_n)
        t = sol_n.t
        t_spikes = sol_n.t_spikes
        n = p_model.nociceptor
        n_current = retrieve_nociceptor_currents(sol_n, p_model)

        init_freq, sust_freq, pattern = get_firing_pattern(t_spikes, p_model.stimulation.off)
        println("DRG neuron init frequency: $(init_freq) - sustained frequency: $(sust_freq) - pattern: $(pattern)")

        voltage = 1
        if voltage != 0
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "Voltage (mV)", ylims=(-100,50), yticks=yticks)

            plot!(plt[voltage], t, sol_n.V, color = something(color, :black), label="", linewidth=1.0)
        end

        instant_freq = 2
        if instant_freq != 0
            t_spikes = sol_n.t_spikes
            freqs = instant_freqs(t_spikes)
            ylabel!(plt[instant_freq], "Instant freq (Hz)")

            plot!(plt[instant_freq], t_spikes[1:end-1], freqs, color = something(color, :black), label="", marker=:circle, markersize=3, markerstrokecolor = :match, markerstrokewidth = 0.0)
            hline!(plt[instant_freq], [init_freq], color = :red, label="f_init")
            hline!(plt[instant_freq], [sust_freq], color = :blue, label="f_sust")
        end

        current_space = 0
        if current_space != 0 
            VEC_Iion = [n_current.INaV1p3, n_current.INaV1p7, n_current.INaV1p8, n_current.IK_dr, n_current.IK_M, n_current.IK_AHP, n_current.ILeak]
            Iion_labels = ["INaV1p3","INaV1p7","INaV1p8","IK_dr","IK_M","IK_AHP","ILeak"]
            Iion_colors = [:blue, :red, :green, :orange, :purple, :brown, :grey]

            add_current_space(plt[current_space], nothing, t, VEC_Iion, Iion_colors, Iion_labels)
        end

        current = 0
        if current != 0
            alpha = 0.9
            ylabel!(plt[current], "Current (µA/cm2)")

            plot!(plt[current], t, n_current.ILeak, color = :grey, label="ILeak", alpha=alpha)
            plot!(plt[current], t, n_current.INaV1p7, color = :red, label="INaV1p7", alpha=alpha)
            plot!(plt[current], t, n_current.INaV1p8, color = :green, label="INaV1p8", alpha=alpha)
            #plot!(plt[current], t, n_current.INaV1p3, color = :blue, label="INaV1p3", alpha=alpha)
        end
    end

    # --------------------- PROJECTION NEURON --------------------- #
    if !isnothing(sol_pn)
        t = sol_pn.t
        t_spikes = sol_pn.t_spikes
        pn = p_model.projection_neuron
        pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)
        
        init_freq, sust_freq, pattern = get_firing_pattern(t_spikes, p_model.stimulation.off)
        println("¨Projection neuron init frequency: $(init_freq) - sustained frequency: $(sust_freq) - pattern: $(pattern)")

        voltage = 1
        if voltage != 0
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "PrjN Voltage (mV)", ylims=(-100,50), yticks=yticks)

            plot!(plt[voltage], t, sol_pn.V, color = something(color, :black), label="", linewidth=1.0)
        end

        instant_freq = 0
        if instant_freq != 0
            freqs = instant_freqs(t_spikes)
            ylabel!(plt[instant_freq], "Instant freq")
            plot!(plt[instant_freq], t_spikes[1:end-1], freqs, color = something(color, :black), label="", marker=:circle, markersize=1.5, markerstrokecolor = :match, markerstrokewidth = 0.0)
        end
    end

    # --------------------- SYNAPSE --------------------- #
    if !isnothing(sol_s)
        t = sol_s.t
        s_current = retrieve_synapse_currents(sol_s, p_model)
    end
end

function make_simulations(VEC_p_model, u0, duration, VEC_label, DIV, with_nociceptor, with_projection_neuron; file_prefix = "default")

    println("")
    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$DIV]")
    println("Simulation of [$duration] ms")
    println("Nociceptor is [$(with_nociceptor)] and projection neuron is [$(with_projection_neuron)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")

    n_fig = 2
    size = (400, 175*n_fig)

    xlimits = (275.0, duration)
    xticks = :native #[300.0, 2000.0]
    # x_label_size = 9
    # x_tick_size = 9
    
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = size, xaxis = nothing, bottom_margin = 0mm, margin = 5mm)
    plot!(plt[end], xaxis = "Time (ms)", xticks=xticks)
    
    for i in 1:(n_fig)
        plot!(plt[i], xticks=xticks)
        plot!(plt[i], legendfontsize=6)
    end

    for i in 1:(n_fig-1)
        plot!(plt[i], xformatter = _ -> "")
    end
    
    L = length(VEC_p_model)
    if L > 1
        VEC_color = palette(:rainbow, L)
        for (i,(p_model, label, color)) in enumerate(zip(VEC_p_model, VEC_label, VEC_color))

            println("-------------- $(i)/$(L) ---------------")
            sol_n, sol_pn, sol_s = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)
        
            println("---- plot ----")
            plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, i; color = color, label = label)
            println("----------------------------------------") 
        end
    else # if L == 1
        p_model = VEC_p_model[1]
        println("-------------- Single ---------------")
        sol_n, sol_pn, sol_s = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)

        println("---- plot ----")
        plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, 1)
        println("----------------------------------------") 
    end

    savefig(plt, "plots/simulation/$(file_prefix).svg")
    return
end

