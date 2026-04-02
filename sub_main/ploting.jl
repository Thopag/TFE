__precompile__(true)
module Ploting

using Plots, LaTeXStrings
#plotlyjs()

export empty_voltage_plot, plot_voltage, plot_all, plot_analyses, plot_param_plan

# Pattern :

label_list = ["No spike", "Single spike", "Two spikes", "Transient", "Spiking"]

# circle : No spike
# utriangle : Single spike 
# :dtriangle : Two spikes 
# diamond : Transient
# square : Spiking
markers_list = [:circle, :utriangle, :dtriangle, :diamond, :square]

# blue : No spike
# darkgreen : Single spike 
# yellowgreen : Two spikes
# orange : Transient
# red3 : Spiking
colors_list = [:midnightblue, :darkgreen, :yellowgreen, :orange, :red3]

function empty_voltage_plot(; xlimits=(400, 1700))
    p = plot(xlims=xlimits, xlabel="Time (ms)", ylabel= "Voltage (mV)")
    return p
end

function plot_voltage(t, V, amp, peaks_idx; given_p=nothing, with_peak=false, save=false)

    if isnothing(given_p)
        p = plot(t, V, label=L"%$amp pA", color= :black; xlimits=(400, 1700))
        xlabel!(p, "Time (ms)")
        ylabel!(p, "Voltage (mV)")
    else
        p = given_p
        plot!(p, t, V, label=L"%$amp pA", color= :black)
    end

    if with_peak && length(peaks_idx) > 0
        scatter!(p, t[peaks_idx], V[peaks_idx], label="", markersize=3, color=:red)
    end

    if save == true
        savefig(p, "plots/plot_voltage.pdf")
        print("save plot voltage\n")
        display(p)
    end

    return p
end

function plot_all(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                            I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, p
                                ; xlimits=(400, 1700))

    n_fig = 3
    alpha = 1
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (1000, 900), xaxis = nothing)

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", legend = :topright, ylims=(-90,40))
    plot!(plt[voltage], t, V, color= :black, label=L"%$amp pA")
    #vline!(plt[voltage], t_spikes, color=:red, label="peaks")

    # variable = 4
    # ylabel!(plt[variable], "Variable (-)")
    # #plot!(plt[variable], ylims=(0, 0.25))
    # plot!(plt[variable], legend = :bottomright)
    # plot!(plt[variable], t, m3, label=L"m_{3}", linestyle = :solid, color=:blue, alpha=alpha)
    # plot!(plt[variable], t, h3, label=L"h_{3}", linestyle = :dash, color=:blue, alpha=alpha)
    # plot!(plt[variable], t, m7, label=L"m_{7}", linestyle = :solid, color=:red, alpha=alpha)
    # plot!(plt[variable], t, h7, label=L"h_{7}", linestyle = :dash, color=:red, alpha=alpha)
    # plot!(plt[variable], t, m8, label=L"m_{8}", linestyle = :solid, color=:green)
    # plot!(plt[variable], t, h8, label=L"h_{8}", linestyle = :dash, color=:green)
    # plot!(plt[variable], t, ndr, label=L"n_{dr}", linestyle = :solid, color=:orange, alpha=alpha)
    # plot!(plt[variable], t, ldr, label=L"l_{dr}", linestyle = :dash, color=:orange, alpha=alpha)
    # plot!(plt[variable], t, nm, label=L"n_{m}", linestyle = :solid, color=:purple, alpha=alpha)
    # plot!(plt[variable], t, z_AHP, label=L"z_{AHP}", linestyle = :solid, color=:brown, alpha=alpha)

    # channel = 2
    # ylabel!(plt[channel], "Channel Availability (%)")
    # #plot!(plt[channel], ylims=(0,50))
    # plot!(plt[channel], t, m3.^3 .* h3 .* 100, color=:blue, label=L"NaV_{1.3}")
    # plot!(plt[channel], t, m7.^3 .* h7 .* 100, color=:red, label=L"NaV_{1.7}")
    # plot!(plt[channel], t, m8.^3 .* h8 .* 100, color=:green, label=L"NaV_{1.8}")
    # plot!(plt[channel], t, ndr.^3 .* ldr .* 100, color=:orange, label=L"K_{dr}", alpha=alpha)
    # plot!(plt[channel], t, nm .* 100, color=:purple, label=L"K_{m}", alpha=alpha)
    # plot!(plt[channel], t, z_AHP .* 100, color=:brown, label=L"K_{AHP}", alpha=alpha)

    i_dV_dt = 2
    ylabel!(plt[i_dV_dt], "dV_dt (mV/s)")
    plot!(plt[i_dV_dt], t, dV_dt, color=:black, label="")

    current = 3
    ylabel!(plt[current], "Current (uA/cm2)", legendfontsize=6, legend = :bottomright)
    plot!(plt[current], ylims=(-(p.I0 + p.Excitation)*1.1, (p.I0 + p.Excitation)*1.1))
    #plot!(plt[current], ylims=(-10, 1))
    plot!(plt[current], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}")
    plot!(plt[current], t, I_Kdr, color=:orange, label=L"I_{Kdr}", alpha=alpha)
    plot!(plt[current], t, I_Km, color=:purple, label=L"I_{KM}", alpha=alpha)
    plot!(plt[current], t, I_AHP, color=:brown, label=L"I_{AHP}", alpha=alpha)
    plot!(plt[current], t, I_Leak, color=:black, label=L"I_{Leak}", alpha=alpha)
    plot!(plt[current], t, I_ext, color=:black, linestyle = :dash, label=L"I_{ext}")
    #plot!(p[current], t, I_noise, color=:pink, label=L"I_{noise}")

    # noise = 5
    # plot!(plt[noise], t, I_noise, color=:black, label=L"I_{noise}")
    # vline!(plt[noise], t_spikes, color=:red, label="peaks")

    # global_current = 5
    # ylabel!(plt[global_current], "Current (uA/cm2)")
    # plot!(plt[global_current], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium")
    # plot!(plt[global_current], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")

    # dV_dt = 5
    # ylabel!(plt[dV_dt], "dV/dt * C (mV/s)")
    # plot!(plt[dV_dt], ylims=(-1.2, 1.2))
    # # NO NOISE TERM HERE
    # plot!(plt[dV_dt], t, I_ext .- I_NaV1p3 .- I_NaV1p7 .- I_NaV1p8 .- I_Kdr .- I_Km .- I_Leak .- I_AHP, color=:black, label="")

    plot!(plt[n_fig], xaxis = "Time (ms)", ticks = :native)

    return plt
end

function plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_pattern_vec, all_first_window_count, all_label; xlabel="amp pA")

    println("------ Start plots ------")

    p_peaks = plot(xlabel=xlabel, ylabel= "Peaks count (-)", title="peaks count")
    p_freqs = plot(xlabel=xlabel, ylabel= "Frequence (Hz)", title="FI curve")
    p_window = plot(xlabel=xlabel, ylabel= "Peaks count (-)", title="First window count")

    for (analysed_values, peaks_count, freqs, pattern_vec, first_window_count, label) in zip(all_analysed_values, all_peaks_count, all_freqs, all_pattern_vec, all_first_window_count, all_label)

        pattern_form = markers_list[pattern_vec .+ 1]

        plot!(p_peaks, analysed_values, peaks_count         , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_freqs, analysed_values, freqs               , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_window, analysed_values, first_window_count , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)

    end

    display(p_peaks)
    display(p_freqs)
    display(p_window)
    savefig(p_peaks, "plots/peaks-curve.pdf")
    savefig(p_freqs, "plots/F-I-curve.pdf")
    savefig(p_window, "plots/window-curve.pdf")


    println("------ End plots ------")
end

function plot_param_plan(all_params, all_pattern_vec, labels; title="")

    plt = plot(xlabel="g NaV 1.7 mS/cm2", ylabel= "g NaV 1.8 mS/cm2", title=title)

    for (params, pattern_vec, label) in zip(all_params, all_pattern_vec, labels)

        pattern_form = markers_list[pattern_vec .+ 1]
        g_nav1p7_s = [p.g_nav1p7 for p in params]
        g_nav1p8_s = [p.g_nav1p8 for p in params]

        plot!(plt, g_nav1p7_s, g_nav1p8_s, marker=pattern_form, markersize=3, linealpha=0.5, markeralpha=0.9, label=label)
    
    end

    display(plt)
    savefig(plt, "plots/$(title)-param_plan.pdf")

end

end