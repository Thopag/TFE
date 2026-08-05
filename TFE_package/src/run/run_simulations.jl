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
        #sol = sol_n
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

function plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, i; color = nothing, label = nothing)

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
        if voltage != 0
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "DRG Voltage (mV)", ylims=(-100,50), yticks=yticks)

            plot!(plt[voltage], t, sol_n.V, color = something(color, :black), label=something(empty_label, ""), linewidth=1)
            #ylims!(plt[voltage], (-75.0, -65.0) )
        end

        currents = 0
        if currents != 0
            var = L"I_{NaV1.7}"
            ylabel!(plt[currents], "$var (µA/cm2)")

            I_K = n_current.IK_M .+ n_current.IK_AHP .+ n_current.IK_dr
            #plot!(plt[currents], t, I_K, color = :cyan, label= L"I_{K}")

            # plot!(plt[currents], t, n_current.INaV1p3, color = something(color, gate_colors["m3"]), label= L"I_{NaV1.3}")
            plot!(plt[currents], t, n_current.INaV1p7, color = something(color, gate_colors["m7"]), label= L"-I_{NaV1.7}")
            # plot!(plt[currents], t, n_current.INaV1p8, color = gate_colors["m8"], label= L"-I_{NaV1.8}")

            # plot!(plt[currents], t, n_current.IK_dr, color = gate_colors["ndr"], label= L"I_{K_{dr}}")
            # plot!(plt[currents], t, n_current.IK_M, color = gate_colors["nM"], label= L"I_{K_M}")
            # plot!(plt[currents], t, n_current.IK_AHP, color = gate_colors["zAHP"], label= L"I_{z_{AHP}}")
            #plot!(plt[currents], t, n_current.ILeak, color = :black, label= L"I_{leak}")

            #plot!(plt[currents], t, n_current.Iext, color = :black, linestyle=:dash, label= L"I_{ext}")
            #ylims!(plt[currents], ( - 0.05*maximum(n_current.Iext), 1.1*maximum(n_current.Iext)) )

            #ylims!(plt[currents], (-0.05, 5.0) )
        end

        gates = 0
        if gates != 0
            var = L"h_7"
            ylabel!(plt[gates], "$var (-)")

            plot!(plt[gates], t, sol_n.h7, color = something(color, gate_colors["h7"]), linestyle=:dash, label="")

        end

    end

    # --------------------- PROJECTION NEURON --------------------- #
    if !isnothing(sol_pn)
        t = sol_pn.t
        pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)
        pn = p_model.projection_neuron

        voltage = 2
        if voltage != 0
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "DH Voltage (mV)", ylims=(-100,50), yticks=yticks)

            # if i == 1 
            #     vline!(plt[voltage], sol_n.t_spikes, color=:red, linestyle=:dash, alpha=0.6, label="")
            # end
            plot!(plt[voltage], t, sol_pn.V, color = something(color, :black), label=something(empty_label, ""), linewidth=1.0)
        end

        Ca = 0
        if Ca != 0
            temp = L"[Ca^{2+}]_i"
            ylabel!(plt[Ca], "$temp (mM)")

            # if i == 1 
            #     vline!(plt[Ca], sol_n.t_spikes, color=:red, linestyle=:dash, alpha=0.6, label="")
            # end
            plot!(plt[Ca], t, sol_pn.Ca_i, color = something(color, :black), label=something(empty_label, ""))
        end

        currents = 0
        if currents != 0
            ylabel!(plt[currents], "Current (µA/cm2)")

            plot!(plt[currents], t, pn_current.Iext, color = :black, label=L"I_{ext}", linewidth=1.5, linestyle=:dash, alpha=1.0)
            #plot!(plt[currents], t, pn_current.INa, color = :red, label=L"I_{Na}", alpha=0.7)
            ylims!(plt[currents], (-15, 10))
        end

        r = 0
        if r != 0
            Ca_o = p_model.projection_neuron.Ca_o
            y = ghk_LeFranc.(sol_pn.V, sol_pn.Ca_i, Ca_o)
            plot!(plt[r], t, y, color = something(color, :black), label=something(empty_label, ""))
        end

    end

    # --------------------- SYNAPSE --------------------- #
    if !isnothing(sol_s)
        t = sol_s.t
        s_current = retrieve_synapse_currents(sol_s, p_model)

        # bin_centers, counts = compute_ccg(sol_n.t_spikes, sol_pn.t_spikes; bin_width=1.0, window=50.0)
        # plt_corr = plot(bin_centers, counts)
        # savefig(plt_corr, "plots/simulation/corr.pdf")

        currents = 0
        if currents != 0
            var = L"I_{NMDA}"
            ylabel!(plt[currents], "$var (µA/cm2)", ylims=(-6,15))
            if i == 1 
                vline!(plt[currents], sol_n.t_spikes, color=:red, linestyle=:dash, alpha=0.6, label="")
            end
            plot!(plt[currents], legend=:topright)

            ICa_i = pn_current.ICa_Lf .+ pn_current.ICa_Ls
            Isyn = s_current.INMDA .+ s_current.IAMPA

            #plot!(plt[currents], t, Isyn, color = :black, label=L"I_{syn}", linestyle=:dot, linewidth=1.5, alpha=0.9)

            #plot!(plt[currents], t, ICa_i, color = something(color, :green), label=something(empty_label, "ICa_i"))
            #plot!(plt[currents], t, s_current.IAMPA, color = :purple, label=L"I_{AMPA}", alpha=0.7) 
            plot!(plt[currents], t, s_current.INMDA, color = :blue, label="", alpha=0.7) 
            
            #plot!(plt[currents], t, ICa_i, color = :green, label=L"I_{[Ca^{2+}]_i}", alpha=0.5) 

            #plot!(plt[currents], t, pn_current.INa, color = :red, label=L"I_{Na}", alpha=0.7)
            #ylims!(plt[currents], (-15, 10))
        end

        channel = 0
        if channel != 0
            ylabel!(plt[channel], "Gates Availability (-)")
            plot!(plt[channel], legend=:topright)

            availability_NMDA = (sol_s.B_NMDA .- sol_s.A_NMDA) # .* NMDA_Mg_block.(sol_pn.V)
            plot!(plt[channel], t, availability_NMDA, color = :blue, label="NMDA", alpha=1.0) 

            availability_AMPA = sol_s.B_AMPA .- sol_s.A_AMPA
            plot!(plt[channel], t, availability_AMPA, color = :purple, label="AMPA", alpha=1.0) 

        end
    end

    # --------------------- STIMULATION --------------------- #

    y_positions = [0, 1]
    y_labels = ["off", "on"]

    stim_binary = 0
    if stim_binary != 0
        amp = p_model.stimulation.amp
        is_activated = p_model.stimulation.is_activated
        ylabel!(plt[stim_binary], "")
        plot!(plt[stim_binary], t, is_activated.(t) .* 1, color= something(color, :black), label=something(empty_label, "")
                                    , xticks=[300.0, 1700.0], yticks = (y_positions, y_labels), ylims=(-0.2,1.2))
    end

    stim_pA = 0
    if stim_pA != 0
        amp = p_model.stimulation.amp
        is_activated = p_model.stimulation.is_activated
        ylabel!(plt[stim_pA], "Stimulation (pA)")
        plot!(plt[stim_pA], t, is_activated.(t) .* amp, color= something(color, :black), label=something(empty_label, "")
                                    , yticks = [6.5, 9.5], xticks=[300])
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
    #size = (750, 175*n_fig)
    #size = (600, 175*n_fig)
    size = (450, 175*n_fig)
    #size = (250, 175*n_fig)
    #size = (300, 150*n_fig)

    x_label_size = 10
    y_label_size = 10

    x_tick_size = 8
    y_tick_size = 8

    # Simulation plot
    xlimits = (0.0, duration)
    xlimits = (275.0, duration)
    xticks = :native #[xlimits[1], xlimits[end]]
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = size, xaxis = nothing, left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    plot!(plt[end], xaxis = "Time (ms)", xticks=xticks)

    for i in 1:(n_fig)
        plot!(plt[i], xticks=xticks, xtickfontsize = x_tick_size, xguidefontsize = x_label_size)
        plot!(plt[i], ytickfontsize = y_tick_size, yguidefontsize = y_label_size)

        #plot!(plt[i], legend=false)
        plot!(plt[i], legendfontsize=6)
    end

    for i in 1:(n_fig-1)
        plot!(plt[i], xformatter = _ -> "")
    end
    
    # size=(450, 150)
    # Freq plot
    p_freq = plot(xaxis = "Time (ms)", yaxis = "DRG Instant frequency (Hz)", xticks=xticks, xlims=xlimits)
    plot!(p_freq, yguidefontsize = 7, legendfontsize=7, size=(size[1], 175), left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    plot!(p_freq, xformatter = _ -> "", xaxis = "")

    L = length(VEC_p_model)
    if L > 1
        VEC_color = palette(:rainbow, L)
        #VEC_color = get_palette(L, :Reds, :red; dark=0.95, light=0.4)
        for (i,(p_model, label, color)) in enumerate(zip(VEC_p_model, VEC_label, VEC_color))

            println("-------------- $(i)/$(L) ---------------")
            sol_n, sol_pn, sol_s, t_spikes, freqs = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)
        
            println("---- plot ----")
            plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, i; color = color, label = label)

            println("----------------------------------------") 
        end
    else # if L == 1

        p_model = VEC_p_model[1]

        println("-------------- Single ---------------")
        sol_n, sol_pn, sol_s, t_spikes, freqs = used_simulation(p_model, u0, duration, with_nociceptor, with_projection_neuron)

        println("---- plot ----")
        plot_simulations(plt, p_model, sol_n, sol_pn, sol_s, 1)

        amp = VEC_p_model[1].stimulation.amp
        #annotate_amp(plt[1], amp)

        if length(freqs) > 1
            plot!(p_freq, t_spikes[1:end-1], freqs, color=:black, label="", marker=:circle, markersize=2, markerstrokecolor = :match, markerstrokewidth = 0.0)
        end
        println("----------------------------------------") 
        #plot_spikes(p_model, sol_n, sol_pn, sol_s, file_prefix)
    end

    #savefig(plt, "plots/simulation/$(file_prefix).png")
    savefig(plt, "plots/simulation/$(file_prefix).pdf")
    #savefig(p_freq, "plots/simulation/$(file_prefix)_freqs.pdf")

    l = @layout [
        a{0.15h}
        b{0.85h}
    ]
    merge = plot(p_freq, plt, layout = l, size = (size[1], size[2]), link = :x)
    #savefig(merge, "plots/simulation/$(file_prefix)_merge.pdf")

    println("Save Plots in [plots/simulation/$(file_prefix)]")
    return
end

