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

        voltage = 2
        if voltage != 0
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "Voltage (mV)", ylims=(-100,50), yticks=yticks)

            plot!(plt[voltage], t, sol_n.V, color = something(color, :black), label=something(empty_label, ""), linewidth=1.0)
        end

        currents = 0
        if currents != 0
            var = L"I_{NaV1.7}"
            ylabel!(plt[currents], "Current (µA/cm2)")

            I_K = n_current.IK_M .+ n_current.IK_AHP .+ n_current.IK_dr
            #plot!(plt[currents], t, I_K, color = :cyan, label= L"I_{K}")

            # plot!(plt[currents], t, n_current.INaV1p3, color = something(color, gate_colors["m3"]), label= L"I_{NaV1.3}")
            # plot!(plt[currents], t, .- n_current.INaV1p7, color = something(color, gate_colors["m7"]), label= L"-I_{NaV1.7}")
            plot!(plt[currents], t, .- n_current.INaV1p8, color = gate_colors["m8"], label= L"-I_{NaV1.8}")

            plot!(plt[currents], t, n_current.Iext, color = :black, linestyle=:dash, label= L"I_{ext}")
            #ylims!(plt[currents], ( - 0.05*maximum(n_current.Iext), 1.1*maximum(n_current.Iext)) )
        end

        gates = 0
        if gates != 0
            ylabel!(plt[gates], "Gate variables (-)", ylims=(-0.05,1.0))

            # Sodium
            plot!(plt[gates], t, sol_n.m3, color = something(color, gate_colors["m3"]), linestyle=gate_styles["m3"], label=L"m_3")
            plot!(plt[gates], t, sol_n.h3, color = something(color, gate_colors["h3"]), linestyle=gate_styles["h3"], label=L"h_3")

            plot!(plt[gates], t, sol_n.m7, color = something(color, gate_colors["m7"]), linestyle=gate_styles["m7"], label=L"m_7")
            plot!(plt[gates], t, sol_n.h7, color = something(color, gate_colors["h7"]), linestyle=gate_styles["h7"], label=L"h_7")

            plot!(plt[gates], t, sol_n.m8, color = something(color, gate_colors["m8"]), linestyle=gate_styles["m8"], label=L"m_8")
            plot!(plt[gates], t, sol_n.h8, color = something(color, gate_colors["h8"]), linestyle=gate_styles["h8"], label=L"h_8")

            ylabel!(plt[gates+1], "Gate variables (-)", ylims=(-0.05,1.0))

            # Potassium
            plot!(plt[gates+1], t, sol_n.ndr, color = something(color, gate_colors["ndr"]), linestyle=gate_styles["ndr"], label=L"n_{dr}")
            plot!(plt[gates+1], t, sol_n.ldr, color = something(color, gate_colors["ldr"]), linestyle=gate_styles["ldr"], label=L"l_{dr}")

            plot!(plt[gates+1], t, sol_n.nM, color = something(color, gate_colors["nM"]), linestyle=gate_styles["mM"], label=L"n_M")
            plot!(plt[gates+1], t, sol_n.zAHP, color = something(color, gate_colors["zAHP"]), linestyle=gate_styles["zAHP"], label=L"z_{AHP}")
        end

        instant_freq = 1
        if instant_freq != 0
            t_spikes = sol_n.t_spikes
            ylabel!(plt[instant_freq], "TO ADD", ylims=(50,100))
            freqs = instant_freqs(t_spikes)
            freq, pattern = get_excitability(t_spikes, p_model.stimulation.off)

            plot!(plt[instant_freq], t_spikes[1:end-1], freqs, color = something(color, :black), label=something(empty_label, "")
                                                                    , marker=:circle, markersize=3, markerstrokecolor = :match, markerstrokewidth = 0.0)
            println()
            println("Nociceptor frequency : $freq")
        end

    end

    # --------------------- PROJECTION NEURON --------------------- #
    if !isnothing(sol_pn)
        t = sol_pn.t
        pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)
        pn = p_model.projection_neuron

        voltage = 2
        if voltage != 1
            yticks= [-90, -65, -40, 0, 30]
            ylabel!(plt[voltage], "PrjN Voltage (mV)", ylims=(-100,50), yticks=yticks)

            # if i == 1 
            #     vline!(plt[voltage], sol_n.t_spikes, color=:red, linestyle=:dash, alpha=0.6, label="")
            # end
            plot!(plt[voltage], t, sol_pn.V, color = something(color, :black), label=something(empty_label, ""), linewidth=1.0)
        end

        gates = 0
        if gates != 0
            ylabel!(plt[gates], "Gate variables (-)", ylims=(-0.05,1.0))
            # plot!(plt[gates], t, sol_pn.mNa, color = something(color, gate_colors["mNa"]), linestyle=gate_styles["mNa"], label=L"m_{Na}")
            # plot!(plt[gates], t, sol_pn.hNa, color = something(color, gate_colors["hNa"]), linestyle=gate_styles["hNa"], label=L"h_{Na}")

            # ylabel!(plt[gates+1], "Gate variables (-)", ylims=(-0.05,1.0))
            # plot!(plt[gates+1], t, sol_pn.mdr, color = something(color, gate_colors["mdr"]), linestyle=gate_styles["mdr"], label=L"m_{dr}")
            # plot!(plt[gates+1], t, sol_pn.mir, color = something(color, gate_colors["mir"]), linestyle=gate_styles["mir"], label=L"m_{ir}")

            plot!(plt[gates], t, sol_pn.mLs, color = something(color, gate_colors["mLs"]), linestyle=gate_styles["mLs"], label=L"m_{Ls}")
            plot!(plt[gates], t, sol_pn.hLs, color = something(color, gate_colors["hLs"]), linestyle=gate_styles["hLs"], label=L"h_{Ls}")
        end

        instant_freq = 0
        if instant_freq != 0
            t_spikes = sol_pn.t_spikes
            freqs = instant_freqs(t_spikes)
            freq, pattern = get_excitability(t_spikes, p_model.stimulation.off)

            plot!(plt[instant_freq], t_spikes[1:end-1], freqs, color = something(color, :black), label=something(empty_label, "")
                                                                    , marker=:circle, markersize=1.5, markerstrokecolor = :match, markerstrokewidth = 0.0)

            println()
            println("Projection neuron frequency : $freq")
        end

        Ca = 0
        if Ca != 0
            temp = L"[Ca^{2+}]_i"
            ylabel!(plt[Ca], "$temp (mM)")
            plot!(plt[Ca], t, sol_pn.Ca_i, color = something(color, :black), label=something(empty_label, ""))
        end

        currents = 0
        if currents != 0
            var = L"I_{Ca_{Ls}}"
            ylabel!(plt[currents], "$var (µA/cm2)")
            plot!(plt[currents], t, pn_current.ICa_Ls, color = something(color, :black), label="", alpha=0.9)
            #plot!(plt[currents], t, pn_current.INa, color = something(color, :red), label="", alpha=0.9)
        end

    end

    # --------------------- SYNAPSE --------------------- #
    if !isnothing(sol_s)
        t = sol_s.t
        s_current = retrieve_synapse_currents(sol_s, p_model)

        currents = 0
        if currents != 0
            ylabel!(plt[currents], "Current (µA/cm2)")
            Isyn = s_current.INMDA .+ s_current.IAMPA
            #plot!(plt[currents], t, Isyn, color = something(color, :black), linestyle=:dash, label=L"I_{syn}", alpha=0.9)
            #plot!(plt[currents], t, s_current.IAMPA, color = something(color, :purple), label=L"I_{AMPA}", alpha=0.7) 
            plot!(plt[currents], t, s_current.INMDA, color = something(color, :blue), label=L"I_{NMDA}", alpha=0.7) 
        end

        channel = 0
        if channel != 0
            ylabel!(plt[channel], "Gates Availability (-)")
            plot!(plt[channel], legend=:topright)

            availability_NMDA = (sol_s.B_NMDA .- sol_s.A_NMDA) #.* NMDA_Mg_block.(sol_pn.V)
            plot!(plt[channel], t, availability_NMDA, color = :blue, label="NMDA", alpha=1.0) 

            # availability_AMPA = sol_s.B_AMPA .- sol_s.A_AMPA
            # plot!(plt[channel], t, availability_AMPA, color = :purple, label="AMPA", alpha=1.0) 
        end
    end

    # --------------------- STIMULATION --------------------- #
    stim_pA = 0
    if stim_pA != 0
        amp = p_model.stimulation.amp
        is_activated = p_model.stimulation.is_activated
        ylabel!(plt[stim_pA], "Stimulation (pA)")
        plot!(plt[stim_pA], t, is_activated.(t) .* amp, color= something(color, :black), label=something(empty_label, ""))
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
    size = (450, 175*n_fig)

    x_label_size = 10
    y_label_size = 10

    x_tick_size = 8
    y_tick_size = 8

    # Simulation plot
    xlimits = (275.0, duration)
    xticks = :native
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = size, xaxis = nothing, left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    plot!(plt[end], xaxis = "Time (ms)", xticks=xticks)

    for i in 1:(n_fig)
        plot!(plt[i], xticks=xticks, xtickfontsize = x_tick_size, xguidefontsize = x_label_size)
        plot!(plt[i], ytickfontsize = y_tick_size, yguidefontsize = y_label_size)
        plot!(plt[i], legendfontsize=6)
    end

    for i in 1:(n_fig-1)
        plot!(plt[i], xformatter = _ -> "")
    end
    
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
        println("----------------------------------------") 
    end

    savefig(plt, "plots/simulation/$(file_prefix).svg")
    return
end

