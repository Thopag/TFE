export init_plot_all, plot_all, several_plot_all, plot_parameter_analyses, sodium_palettes

const pattern_list   = ["No spike"    , "Single spike", "Two spikes", "Transient" , "Spiking" ]
const markers_list   = [:circle       , :utriangle    , :dtriangle  , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :yellowgreen, :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

function sodium_palettes(L; dark=0.95, light=0.4)

    if L == 1
        return [:red], [:blue], [:green], [:grey]
    end

    reds = [get(colorschemes[:Reds], i) for i in range(light, stop=dark, length=L)]
    blues = [get(colorschemes[:Blues], i) for i in range(light, stop=dark, length=L)]
    greens = [get(colorschemes[:Greens], i) for i in range(light, stop=dark, length=L)]
    greys = [get(colorschemes[:Greys], i) for i in range(light, stop=dark, length=L)]

    return reds, blues, greens, greys
end

function init_plot_all(; xlimits=(400, 1700))
    n_fig = 3
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (750, 230*n_fig), xaxis = nothing,
                                                                    left_margin = 5mm,
                                                                    bottom_margin = 5mm, 
                                                                    margin = 5mm)
    xticks = xlimits[1]:25:xlimits[end] #range(xlimits[1], xlimits[end], length=10)
    plot!(plt[n_fig], xaxis = "Time (ms)", xticks=xticks)
    return plt
end

function plot_all(plt, t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                            I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, param)

    alpha = 0.4

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", legend = :topright, ylims=(-90,50))
    xlims = Plots.xlims(plt[voltage])
    ylims = Plots.ylims(plt[voltage])
        
    plot!(plt[voltage], t, V, color= :black, label="")
    #vline!(plt[voltage], t_spikes, color=:red, label="peaks")
    annotate!(plt[voltage],
        xlims[2] - 0.1*(xlims[2]-xlims[1]),
        ylims[2] - 0.05*(ylims[2]-ylims[1]),
        text( L"amp = %$amp pA", 11, :black))

    current = 2
    ylabel!(plt[current], "Current (uA/cm2)", legendfontsize=7, legend = :bottomright)
    plot!(plt[current], ylims=(-(param.I0 + param.Excitation)*1.7, (param.I0 + param.Excitation)*1.7))
    #plot!(plt[current], ylims=(-20, 20))
    plot!(plt[current], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}")
    plot!(plt[current], t, I_Kdr, color=:orange, label=L"I_{Kdr}", alpha=alpha)
    plot!(plt[current], t, I_Km, color=:purple, label=L"I_{KM}", alpha=alpha)
    plot!(plt[current], t, I_AHP, color=:brown, label=L"I_{AHP}", alpha=alpha)
    plot!(plt[current], t, I_Leak, color=:black, label=L"I_{Leak}", alpha=alpha)
    plot!(plt[current], t, .- I_ext, color=:black, linestyle = :dash, label=L"-I_{ext}")
    #plot!(p[current], t, I_noise, color=:pink, label=L"I_{noise}")

    current_no_zoom = 3
    ylabel!(plt[current_no_zoom], "Current (uA/cm2)", legendfontsize=7, legend = :bottomright)
    plot!(plt[current_no_zoom], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", alpha=alpha)
    plot!(plt[current_no_zoom], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}", alpha=alpha)
    plot!(plt[current_no_zoom], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}")
    plot!(plt[current_no_zoom], t, I_Kdr, color=:orange, label=L"I_{Kdr}", alpha=alpha)
    plot!(plt[current_no_zoom], t, I_Km, color=:purple, label=L"I_{KM}", alpha=alpha)
    plot!(plt[current_no_zoom], t, I_AHP, color=:brown, label=L"I_{AHP}", alpha=alpha)
    plot!(plt[current_no_zoom], t, I_Leak, color=:black, label=L"I_{Leak}", alpha=alpha)
    plot!(plt[current_no_zoom], t, .- I_ext, color=:black, linestyle = :dash, label=L"-I_{ext}")
    #plot!(p[current], t, I_noise, color=:pink, label=L"I_{noise}")

    # i_dV_dt = 3
    # ylabel!(plt[i_dV_dt], "dV_dt (mV/s)")
    # #plot!(plt[i_dV_dt], ylims=(-0.2, 0.5))
    # plot!(plt[i_dV_dt], t, dV_dt, color=:black, label="")

    # variable = 3
    # ylabel!(plt[variable], "Variable (-)")
    # #plot!(plt[variable], ylims=(0, 0.25))
    # plot!(plt[variable], legend = :bottomright)
    # plot!(plt[variable], t, m3, label=L"m_{3}", linestyle = :solid, color=:blue, alpha=alpha)
    # plot!(plt[variable], t, h3, label=L"h_{3}", linestyle = :dash, color=:blue, alpha=alpha)
    # plot!(plt[variable], t, m7, label=L"m_{7}", linestyle = :solid, color=:red, alpha=alpha)
    # plot!(plt[variable], t, h7, label=L"h_{7}", linestyle = :dash, color=:red, alpha=alpha)
    # plot!(plt[variable], t, m8, label=L"m_{8}", linestyle = :solid, color=:green, alpha=alpha)
    # plot!(plt[variable], t, h8, label=L"h_{8}", linestyle = :dash, color=:green, alpha=alpha)
    # plot!(plt[variable], t, ndr, label=L"n_{dr}", linestyle = :solid, color=:orange)
    # plot!(plt[variable], t, ldr, label=L"l_{dr}", linestyle = :dash, color=:orange)
    # plot!(plt[variable], t, nm, label=L"n_{m}", linestyle = :solid, color=:purple)
    # plot!(plt[variable], t, z_AHP, label=L"z_{AHP}", linestyle = :solid, color=:brown, alpha=alpha)

    # channel = 3
    # ylabel!(plt[channel], "Channel Availability (%)")
    # # plot!(plt[channel], ylims=(-0.05,1))
    # plot!(plt[channel], t, m3.^3 .* h3 .* 100, color=:blue, label=L"NaV_{1.3}")
    # plot!(plt[channel], t, m7.^3 .* h7 .* 100, color=:red, label=L"NaV_{1.7}")
    # plot!(plt[channel], t, m8.^3 .* h8 .* 100, color=:green, label=L"NaV_{1.8}")
    # plot!(plt[channel], t, ndr.^3 .* ldr .* 100, color=:orange, label=L"K_{dr}")
    # plot!(plt[channel], t, nm .* 100, color=:purple, label=L"K_{m}")
    # plot!(plt[channel], t, z_AHP .* 100, color=:brown, label=L"K_{AHP}")

    # global_current = 5
    # ylabel!(plt[global_current], "Current (uA/cm2)")
    # plot!(plt[global_current], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium")
    # plot!(plt[global_current], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")

    return plt
end

function several_plot_all(plt, color, t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                            I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, param; label="")

    alpha = 0.4

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", legend = :topright, ylims=(-90,50))
    plot!(plt[voltage], t, V, color=color, label=label)
    #vline!(plt[voltage], t_spikes, color=:red, label="peaks")

    current = 2
    ylabel!(plt[current], "Current (uA/cm2)", legendfontsize=7, legend = :topright)
    plot!(plt[current], ylims=(-(param.I0 + param.Excitation)*1.7, (param.I0 + param.Excitation)*1.7))
    #plot!(plt[current], ylims=(-20, 20))
    # plot!(plt[current], t, I_NaV1p3, color=color, label=L"I_{NaV1.3} - %$label")
    # plot!(plt[current], t, I_NaV1p7, color=color, label=L"I_{NaV1.7} - %$label")
    plot!(plt[current], t, I_NaV1p8, color=color, label=L"I_{NaV1.8} - %$label")
    # plot!(plt[current], t, I_Kdr, color=color, label=L"I_{Kdr} - %$label")
    # plot!(plt[current], t, I_Km, color=color, label=L"I_{KM} - %$label")
    # plot!(plt[current], t, I_AHP, color=color, label=L"I_{AHP} - %$label")
    # plot!(plt[current], t, I_Leak, color=color, label=L"I_{Leak} - %$label")
    plot!(plt[current], t, .- I_ext, color=color, linestyle = :dash, label=L"-I_{ext} - %$label")
    #plot!(p[current], t, I_noise, color=color, label=L"I_{noise}")

    current_no_zoom = 3
    ylabel!(plt[current_no_zoom], "Current (uA/cm2)", legendfontsize=7, legend = :bottomright)
    # plot!(plt[current_no_zoom], t, I_NaV1p3, color=color, label=L"I_{NaV1.3} - %$label")
    # plot!(plt[current_no_zoom], t, I_NaV1p7, color=color, label=L"I_{NaV1.7} - %$label")
    plot!(plt[current_no_zoom], t, I_NaV1p8, color=color, label=L"I_{NaV1.8} - %$label")
    # plot!(plt[current_no_zoom], t, I_Kdr, color=color, label=L"I_{Kdr} - %$label")
    # plot!(plt[current_no_zoom], t, I_Km, color=color, label=L"I_{KM} - %$label")
    # plot!(plt[current_no_zoom], t, I_AHP, color=color, label=L"I_{AHP} - %$label")
    # plot!(plt[current_no_zoom], t, I_Leak, color=color, label=L"I_{Leak} - %$label")
    plot!(plt[current_no_zoom], t, .- I_ext, color=color, linestyle = :dash, label=L"-I_{ext} - %$label")
    #plot!(p[current], t, I_noise, color=color, label=L"I_{noise}")

    return plt
end

function plot_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)

    # ----- INIT ----- #

    p_peaks = plot(xlabel=intra_axe_label, ylabel= "Peaks count (-)")
    p_freqs = plot(xlabel=intra_axe_label, ylabel= "Frequence (Hz)")
    p_height = plot(xlabel=intra_axe_label, ylabel= "Height (mV)")
    p_width = plot(xlabel=intra_axe_label, ylabel= "width (ms)")

    p_rheo = plot(xlabel=inter_axe_label, ylabel="rheobase (pA)")
    p_plan = plot(xlabel=intra_axe_label, ylabel=inter_axe_label, legend=:topright, legendfontsize=7)
    p_pattern = plot(xlabel=intra_axe_label, ylabel=inter_axe_label, yticks = (1:length(inter_labels), inter_labels), legend=:topright, legendfontsize=7)

    # Add color legend
    for (c, l) in zip(colors_list, pattern_list)
        scatter!(p_pattern, [], [], marker=:square, color = c, label = l, markersize = 4)
        #scatter!(p_plan, [], [], marker=:square, color = c, label = l, markersize = 4)
    end
    
    # ----- Fill plots ----- #

    for (i,(VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w, inter_label)) in 
                        enumerate(zip(eachcol(M_peak_count), eachcol(M_freq), eachcol(M_pattern), eachcol(M_first_peak_h), eachcol(M_first_peak_w), inter_labels))

        pattern_form = markers_list[VEC_pattern .+ 1]
        pattern_color = colors_list[VEC_pattern .+ 1]

        plot!(p_peaks, VEC_intra_parameter, VEC_peak_count      , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.9, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_freqs, VEC_intra_parameter, VEC_freq            , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.9, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        plot!(p_height, VEC_intra_parameter, VEC_first_peak_h   , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.9, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_width, VEC_intra_parameter, VEC_first_peak_w    , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.9, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        bar!(p_pattern, VEC_intra_parameter, fill(i+0.5, length(VEC_intra_parameter)), fillto=fill(i-0.45, length(VEC_intra_parameter)), 
                                                                        lw=0, linecolor=:match, bar_width=(VEC_intra_parameter[1]-VEC_intra_parameter[2])*1.05, label="", color=pattern_color)
    end

    # -------- Finish Ploting -------- #

    # --- rheobase barplot --- #
    bar!(p_rheo, inter_with_rheobase, rheobases, label="")
    annotate!(inter_with_rheobase, rheobases ./ 2, text.(string.(rheobases), :center, :center, :white, 7))

    # --- Pattern Plan (Heatmap) --- #
    number_pattern = length(pattern_list) - 1
    heatmap!(p_plan, VEC_intra_parameter, VEC_inter_parameter, M_pattern', clims = (-0.5, number_pattern + 0.5), colorbar=false, fillcolor = pattern_palette, interpolate=false)

    if length(VEC_intra_parameter) > 1
        diff_x = VEC_intra_parameter[2]-VEC_intra_parameter[1]
    else
        diff_x = VEC_intra_parameter[1]
    end
    if length(VEC_inter_parameter) > 1
        diff_y = VEC_inter_parameter[2]-VEC_inter_parameter[1]
    else
        diff_y = VEC_inter_parameter[1]
    end

    x_limits = (-diff_x/8, VEC_intra_parameter[end] + diff_x/8)
    y_limits = (-diff_y/8, VEC_inter_parameter[end] + diff_y/8)

    plot!(p_plan, xlims=x_limits, ylims=y_limits) #, yscale=:log10)

    ####################################### Lido Traj #####################################################
    #add_lido_shift_inhib_traj(p_plan)

    # Add pattern colorbar
    flag_colors = Dict( 0:number_pattern .=> pattern_list )
    data2 = collect(range((0.0,number_pattern)..., 100))
    sdic = sort(flag_colors, by=first)
    p_cbar = heatmap([1], data2, [data2;;], colorbar=false, c=pattern_palette, xaxis=false, tick_direction=:out,
                ymirror=true, yticks=(keys(sdic), values(sdic)))
    l = @layout [a{0.95w} b]
    p_plan = plot(p_plan, p_cbar, layout=l)

    return p_peaks, p_freqs, p_height, p_width, p_rheo, p_plan, p_pattern
end