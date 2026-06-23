export single_simulation, plot_single_simulation

function single_simulation(p_model, u0, duration; file_prefix = "default")

    sol_n  = nothing
    sol_pn = nothing
    sol_s  = nothing

    stim = p_model.stimulation

    print("------------------------------\n")
    println("I_ext : $(stim.amp) pA")

    #@time sol_n = nociceptor_simulation(u0, (0.0, duration), p_model)
    #@time sol_pn = projection_neuron_simulation(u0, (0.0, duration), p_model)
    @time sol_n, sol_pn, sol_s = with_synapse_simulation(u0, (0.0, duration), p_model)

    sol = sol_n
    t_spikes = sol.t_spikes

    freqs = instant_freqs(t_spikes)
    freq, pattern = get_excitability(t_spikes, stim.off)
    pred_pattern  = pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")
    print("------------------------------\n")

    return sol_n, sol_pn, sol_s
end

function plot_single_simulation(sol_n, sol_pn, sol_s, p_model, duration; file_prefix = "default")

    n_fig = 4

    xlimits = (0.0, duration)
    xticks = :native #xlimits[1]:100:xlimits[end]
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (750, 230*n_fig), xaxis = nothing,
                                                                    left_margin = 5mm,
                                                                    bottom_margin = 5mm, 
                                                                    margin = 5mm)

    plot!(plt[n_fig], xaxis = "Time (ms)", xticks=xticks)

    t = sol_n.t
    V = sol_n.V
    amp = p_model.stimulation.amp

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", ylims=(-100,50))
    xlims = Plots.xlims(plt[voltage])
    ylims = Plots.ylims(plt[voltage])

    plot!(plt[voltage], t, V, color= :black, label="")
    #vline!(plt[voltage], sol_n.t_spikes, color=:red, label="")
    annotate!(plt[voltage],
        xlims[2] - 0.1*(xlims[2]-xlims[1]),
        ylims[2] - 0.05*(ylims[2]-ylims[1]),
        text( L"amp = %$amp pA", 11, :black))


    voltage_pn = 2
    ylabel!(plt[voltage_pn], "Voltage (mV)", ylims=(-100,50))
    plot!(plt[voltage_pn], t, sol_pn.V, color= :black, label="")

    s_current = retrieve_synapse_currents(sol_s, p_model)
    syn_curr = 3
    plot!(plt[syn_curr], t, .-s_current.INMDA, label="-INMDA")
    plot!(plt[syn_curr], t, .-s_current.IAMPA, label="-IAMPA")
    #vline!(plt[3], sol_s.t_NMDA_response, color=:red, label="")

    # syn_variables = 4
    # plot!(plt[syn_variables], t, sol_s.A_NMDA,  label="A_NMDA", color= :purple)
    # plot!(plt[syn_variables], t, sol_s.B_NMDA,  label="B_NMDA", color= :blue)
    # plot!(plt[syn_variables], t, sol_s.Use_NMDA,  label="Use_NMDA", color= :green)
    # plot!(plt[syn_variables], t, sol_s.P_NMDA,  label="P_NMDA ", color= :orange)
    # plot!(plt[syn_variables], t, sol_s.B_NMDA .- sol_s.A_NMDA,  label="B_NMDA - A_NMDA", color= :red)

    t_resp, resp = reponse_time(p_model.save.t_NMDA_response, t)
    response = 4
    plot!(plt[response], t_resp, resp,  label="response", color= :black)

    # n_current = retrieve_projection_neuron_currents(sol_n, p_model)
    # plot!(plt[4], t, n_current.Iext, label="Iext")

    # --- plot frequencies --- #

    sol = sol_n
    t_spikes = sol.t_spikes
    freqs = instant_freqs(t_spikes)

    if length(freqs) > 1
        p_freq = plot(t_spikes[1:end-1], freqs, label="", marker=:circle, markersize=4, markerstrokecolor = :match, markerstrokewidth = 0.0)
    else
        p_freq = plot()
    end

    # --- save --- #

    savefig(plt, "plots/simulation/$(file_prefix).png")
    savefig(plt, "plots/simulation/$(file_prefix).pdf")
    savefig(p_freq, "plots/simulation/$(file_prefix)_freqs.pdf")

    println("Save Plots in [plots/simulation/$(file_prefix)]")
    return plt, p_freq
end
