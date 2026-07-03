export single_simulation, plot_single_simulation

function single_simulation(p_model, u0, duration; file_prefix = "default")

    sol_n  = nothing
    sol_pn = nothing
    sol_s  = nothing

    stim = p_model.stimulation

    print("------------------------------\n")
    println("I_ext : $(stim.amp) pA")

    #@time sol_n, sol_pn, sol_s = nociceptor_simulation(u0, (0.0, duration), p_model)
    #@time sol_n, sol_pn, sol_s = projection_neuron_simulation(u0, (0.0, duration), p_model)
    @time sol_n, sol_pn, sol_s = with_synapse_simulation(u0, (0.0, duration), p_model)

    sol = sol_pn
    t_spikes = sol.t_spikes

    freqs = instant_freqs(t_spikes)
    freq, pattern = get_excitability(t_spikes, stim.off)
    pred_pattern  = pattern_list[pattern+1]
    println("Predicted pattern : $pred_pattern")
    print("------------------------------\n")

    return sol_n, sol_pn, sol_s
end

function plot_single_simulation(sol_n, sol_pn, sol_s, p_model, duration; file_prefix = "default")

    n_fig = 6

    xlimits = (0.0, duration)
    xticks = :native #xlimits[1]:100:xlimits[end]
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (750, 230*n_fig), xaxis = nothing,
                                                                    left_margin = 5mm,
                                                                    bottom_margin = 5mm, 
                                                                    margin = 5mm)

    plot!(plt[n_fig], xaxis = "Time (ms)", xticks=xticks)

    sol = sol_pn
    t = sol.t
    amp = p_model.stimulation.amp
    pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)
    s_current = retrieve_synapse_currents(sol_s, p_model)

    voltage_n = 1
    ylabel!(plt[voltage_n], "Voltage (mV)", ylims=(-100,50))
    xlims = Plots.xlims(plt[voltage_n])
    ylims = Plots.ylims(plt[voltage_n])

    plot!(plt[voltage_n], t, sol_n.V, color= :black, label="")
    #vline!(plt[voltage], sol_n.t_spikes, color=:red, label="")
    annotate!(plt[voltage_n],
        xlims[2] - 0.1*(xlims[2]-xlims[1]),
        ylims[2] - 0.05*(ylims[2]-ylims[1]),
        text( L"amp = %$amp pA", 11, :black))

    is_activated = p_model.stimulation.is_activated
    stim = 6
    ylabel!(plt[stim], "Stim")
    #plot!(plt[stim], t, is_activated.(t) .* amp, color= :black, label="")
    plot!(plt[stim], t, pn_current.Iext, color= :black, label="")

    voltage_pn = 2
    ylabel!(plt[voltage_pn], "Voltage (mV)", ylims=(-100,50))
    plot!(plt[voltage_pn], t, sol_pn.V, color= :black, label="")

    Ca = 3
    ylabel!(plt[Ca], "Ca")
    plot!(plt[Ca], t, sol_pn.Ca_i, color= :black, label="")

    # pn_curr = 2
    # ylabel!(plt[pn_curr], "Current")
    # #plot!(plt[pn_curr], t, pn_current.INa, label="INa")
    # plot!(plt[pn_curr], t, pn_current.IK_M, label="IK_M")
    # plot!(plt[pn_curr], t, pn_current.ICa_Ls, label="ICa_Ls")
    # #plot!(plt[pn_curr], t, pn_current.ICa_Lf, label="ICa_Lf")
    # plot!(plt[pn_curr], t, pn_current.IK_ir, label="IK_ir")
    # #plot!(plt[pn_curr], t, s_current.IAMPA .+ s_current.INMDA, label="Isyn") 
    # #plot!(plt[pn_curr], t, pn_current.ICa_Ls .+ pn_current.ICa_Lf, label="ICa_i")
    
    syn_Ca = 4
    #plot!(plt[syn_Ca], t, s_current.ICa_from_syn, label="ICa_from_syn")
    #plot!(plt[syn_Ca], t, s_current.IAMPA .+ s_current.INMDA, label="Isyn") 
    plot!(plt[syn_Ca], t, s_current.INMDA, label="INMDA") 

    syn_var = 5
    plot!(plt[syn_var], t, sol_s.Use_NMDA, label="Use_NMDA") 

    # channel = 3
    # plot!(plt[channel], t, sol_pn.mir, label="mir") 
    # plot!(plt[channel], t, sol_pn.mM, label="mM") 

    # --- plot frequencies --- #

    t_spikes = sol.t_spikes
    freqs = instant_freqs(t_spikes)

    if length(freqs) > 1
        p_freq = plot(t_spikes[1:end-1], freqs, label="", marker=:circle, markersize=4, markerstrokecolor = :match, markerstrokewidth = 0.0)
    else
        p_freq = plot()
    end

    # --- save --- #

    savefig(plt, "plots/simulation/$(file_prefix).png")
    #savefig(plt, "plots/simulation/$(file_prefix).pdf")
    savefig(p_freq, "plots/simulation/$(file_prefix)_freqs.pdf")

    println("Save Plots in [plots/simulation/$(file_prefix)]")
    return plt, p_freq
end
