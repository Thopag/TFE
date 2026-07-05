export make_simulations

function choose_simulation_function(with_nociceptor, with_projection_neuron)

    if with_nociceptor && with_projection_neuron
        simulation_function = with_synapse_simulation
    elseif with_nociceptor
        simulation_function = nociceptor_simulation
    elseif with_projection_neuron
        simulation_function = projection_neuron_simulation
    else
        prinln("(choose_simulation_function) I NEED AT LEAST A NEURON (nociceptor or projection neuron)")
    end
    return simulation_function
end

function used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)

    simulation_function = choose_simulation_function(with_nociceptor, with_projection_neuron)
    @time sol_n, sol_pn, sol_s = simulation_function(u0, (0.0, duration), p_model)

    if !isnothing(sol_pn)
        sol = sol_pn
    else
        sol = sol_n
    end

    t_spikes = sol.t_spikes
    freqs = instant_freqs(t_spikes)
    freq, pattern = get_excitability(t_spikes, p_model.stimulation.off)
    pred_pattern  = pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern - Mean freq : $freq")
    return sol_n, sol_pn, sol_s, t_spikes, freqs
end

function plot_simulations(plt, p_model, sol_n, sol_pn, sol_s; color = nothing, label = nothing)

    # Check if multi or single simulation
    if !isnothing(color) && !isnothing(label)
        plot!(plt[1], [], [], color=color, label=label)
        empty_label = ""
    else
        empty_label = nothing
    end

    # --------------------- NOCICEPTOR --------------------- #
    if !isnothing(sol_n)
        t = sol_n.t
        n_current = retrieve_nociceptor_currents(sol_n, p_model)

        voltage = 1
        ylabel!(plt[voltage], "Voltage (mV)", ylims=(-100,50))
        plot!(plt[voltage], t, sol_n.V, color = something(color, :black), label=something(empty_label, ""))
    
    end

    # --------------------- PROJECTION NEURON --------------------- #
    if !isnothing(sol_pn)
        t = sol_pn.t
        pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)

        voltage = 2
        ylabel!(plt[voltage], "Voltage (mV)")
        plot!(plt[voltage], t, sol_pn.V, color = something(color, :black), label=something(empty_label, ""))

        # Ca = 3
        # ylabel!(plt[Ca], "Intracellular calcium [mM]")
        # plot!(plt[Ca], t, sol_pn.Ca_i, color = something(color, :black), label=something(empty_label, ""))
    
    end

    # --------------------- SYNAPSE --------------------- #
    if !isnothing(sol_s)
        t = sol_s.t
        s_current = retrieve_synapse_currents(sol_s, p_model)

        # current = 4
        # plot!(plt[current], t, s_current.INMDA, color = something(color, :blue), label=something(empty_label, "INMDA")) 
    end

    # --------------------- STIMULATION --------------------- #
    stim = 3
    amp = p_model.stimulation.amp
    is_activated = p_model.stimulation.is_activated
    ylabel!(plt[stim], "Stimulation (pA)")
    plot!(plt[stim], t, is_activated.(t) .* amp, color= something(color, :black), label=something(empty_label, ""))

end

function make_simulations(VEC_p_model, u0, duration, VEC_label, DIV, with_nociceptor, with_projection_neuron; file_prefix = "default")

    println("")
    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$DIV]")
    println("Simulation of [$duration] ms")
    println("Nociceptor is [$(with_nociceptor)] and projection neuron is [$(with_projection_neuron)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")

    n_fig = 3

    # Simulation plot
    xlimits = (0.0, duration)
    xticks = :native #xlimits[1]:100:xlimits[end]
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (750, 230*n_fig), xaxis = nothing, left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    plot!(plt[n_fig], xaxis = "Time (ms)", xticks=xticks)

    # Freq plot
    p_freq = plot(xaxis = "Time (ms)", yaxis = "Instant frequency (Hz)", xticks=xticks, xlims=xlimits)

    L = length(VEC_p_model)
    if L > 1
        VEC_color = palette(:rainbow, L)
        for (i,(p_model, label, color)) in enumerate(zip(VEC_p_model, VEC_label, VEC_color))

            println("-------------- $(i)/$(L) ---------------")
            sol_n, sol_pn, sol_s, t_spikes, freqs = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)
        
            println("---- plot ----")
            plot_simulations(plt, p_model, sol_n, sol_pn, sol_s; color = color, label = label)

            if length(freqs) > 1
                plot!(p_freq, t_spikes[1:end-1], freqs, color=color, label=label, marker=:circle, markersize=2, markerstrokecolor = :match, markerstrokewidth = 0.0)
            end
            println("----------------------------------------") 
        end
    else # if L == 1

        p_model = VEC_p_model[1]

        println("-------------- Single ---------------")
        sol_n, sol_pn, sol_s, t_spikes, freqs = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)

        println("---- plot ----")
        plot_simulations(plt, p_model, sol_n, sol_pn, sol_s)

        amp = VEC_p_model[1].stimulation.amp
        annotate_amp(plt[1], amp)
-
        if length(freqs) > 1
            plot!(p_freq, t_spikes[1:end-1], freqs, color=:black, label="", marker=:circle, markersize=2, markerstrokecolor = :match, markerstrokewidth = 0.0)
        end
        println("----------------------------------------") 
    end

    savefig(plt, "plots/simulation/$(file_prefix).png")
    #savefig(plt, "plots/simulation/$(file_prefix).pdf")
    savefig(p_freq, "plots/simulation/$(file_prefix)_freqs.pdf")

    println("Save Plots in [plots/simulation/$(file_prefix)]")
    return
end

