export plot_all, plot_parameter_analyses, sodium_palettes

const pattern_list   = ["No spike"    , "Single spike", "Two spikes", "Transient" , "Spiking" ]
const markers_list   = [:circle       , :utriangle    , :dtriangle  , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :yellowgreen, :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

function sodium_palettes(L; dark=0.9, light=0.4)

    reds = [get(colorschemes[:Reds], i) for i in range(dark, stop=light, length=L)]
    blues = [get(colorschemes[:Blues], i) for i in range(dark, stop=light, length=L)]
    greens = [get(colorschemes[:Greens], i) for i in range(dark, stop=light, length=L)]
    greys = [get(colorschemes[:Greys], i) for i in range(dark, stop=light, length=L)]
    
    return reds, blues, greens, greys
end

function plot_all(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp, t_spikes,
                            I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak, I_ext, I_noise, dV_dt, p
                                ; xlimits=(400, 1700))

    n_fig = 3
    alpha = 0.3
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (1000, 900), xaxis = nothing)

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", legend = :topright, ylims=(-90,40))
    plot!(plt[voltage], t, V, color= :black, label=L"%$amp pA")
    #vline!(plt[voltage], t_spikes, color=:red, label="peaks")

    variable = 2
    ylabel!(plt[variable], "Variable (-)")
    #plot!(plt[variable], ylims=(0, 0.25))
    plot!(plt[variable], legend = :bottomright)
    plot!(plt[variable], t, m3, label=L"m_{3}", linestyle = :solid, color=:blue, alpha=alpha)
    plot!(plt[variable], t, h3, label=L"h_{3}", linestyle = :dash, color=:blue, alpha=alpha)
    plot!(plt[variable], t, m7, label=L"m_{7}", linestyle = :solid, color=:red, alpha=alpha)
    plot!(plt[variable], t, h7, label=L"h_{7}", linestyle = :dash, color=:red, alpha=alpha)
    plot!(plt[variable], t, m8, label=L"m_{8}", linestyle = :solid, color=:green, alpha=alpha)
    plot!(plt[variable], t, h8, label=L"h_{8}", linestyle = :dash, color=:green, alpha=alpha)
    plot!(plt[variable], t, ndr, label=L"n_{dr}", linestyle = :solid, color=:orange)
    plot!(plt[variable], t, ldr, label=L"l_{dr}", linestyle = :dash, color=:orange)
    plot!(plt[variable], t, nm, label=L"n_{m}", linestyle = :solid, color=:purple)
    plot!(plt[variable], t, z_AHP, label=L"z_{AHP}", linestyle = :solid, color=:brown, alpha=alpha)

    # channel = 2
    # ylabel!(plt[channel], "Channel Availability (%)")
    # plot!(plt[channel], ylims=(-0.05,1))
    # plot!(plt[channel], t, m3.^3 .* h3 .* 100, color=:blue, label=L"NaV_{1.3}")
    # plot!(plt[channel], t, m7.^3 .* h7 .* 100, color=:red, label=L"NaV_{1.7}")
    # plot!(plt[channel], t, m8.^3 .* h8 .* 100, color=:green, label=L"NaV_{1.8}")
    # plot!(plt[channel], t, ndr.^3 .* ldr .* 100, color=:orange, label=L"K_{dr}")
    # plot!(plt[channel], t, nm .* 100, color=:purple, label=L"K_{m}")
    # plot!(plt[channel], t, z_AHP .* 100, color=:brown, label=L"K_{AHP}")

    current = 3 
    ylabel!(plt[current], "Current (uA/cm2)", legendfontsize=6, legend = :bottomright)
    #plot!(plt[current], ylims=(-(p.I0 + p.Excitation)*1.1, (p.I0 + p.Excitation)*1.1))
    plot!(plt[current], ylims=(-20, 20))
    plot!(plt[current], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}", alpha=alpha)
    plot!(plt[current], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}", alpha=alpha)
    plot!(plt[current], t, I_Kdr, color=:orange, label=L"I_{Kdr}")
    plot!(plt[current], t, I_Km, color=:purple, label=L"I_{KM}")
    plot!(plt[current], t, I_AHP, color=:brown, label=L"I_{AHP}", alpha=alpha)
    plot!(plt[current], t, I_Leak, color=:black, label=L"I_{Leak}", alpha=alpha)
    plot!(plt[current], t, I_ext, color=:black, linestyle = :dash, label=L"I_{ext}")
    #plot!(p[current], t, I_noise, color=:pink, label=L"I_{noise}")

    # current_bis = 2
    # ylabel!(plt[current_bis], "Current (uA/cm2)", legendfontsize=6, legend = :bottomright)
    # plot!(plt[current_bis], ylims=(-0.2, 0.01))
    # #plot!(plt[current_bis], ylims=(-10, 1))
    # plot!(plt[current_bis], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", alpha=alpha)
    # plot!(plt[current_bis], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}", alpha=alpha)
    # plot!(plt[current_bis], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}", alpha=alpha)
    # plot!(plt[current_bis], t, .- I_Kdr, color=:orange, label=L"-I_{Kdr}", alpha=alpha)
    # plot!(plt[current_bis], t, .- I_Km, color=:purple, label=L"-I_{KM}", alpha=alpha)
    # plot!(plt[current_bis], t, .- I_AHP, color=:brown, label=L"-I_{AHP}", alpha=alpha)

    # plot!(plt[current_bis], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:pink, label=L"I_{Na}")
    # plot!(plt[current_bis], t, .- I_Kdr .- I_Km .- I_AHP, color=:black, label=L"- I_{K}")
    # plot!(plt[current_bis], t, .- I_Kdr .- I_Km .- I_AHP, color=:black, linestyle = :dash, label=L"- I_{K&leak}")
    # plot!(plt[current_bis], t, I_Leak, color=:black, label=L"I_{Leak}", alpha=alpha)
    # plot!(plt[current_bis], t, I_ext, color=:black, linestyle = :dash, label=L"I_{ext}")

    # i_dV_dt = 3
    # ylabel!(plt[i_dV_dt], "dV_dt (mV/s)")
    # plot!(plt[i_dV_dt], ylims=(-0.2, 0.5))
    # plot!(plt[i_dV_dt], t, dV_dt, color=:black, label="")

    # noise = 5
    # plot!(plt[noise], t, I_noise, color=:black, label=L"I_{noise}")
    # vline!(plt[noise], t_spikes, color=:red, label="peaks")

    # global_current = 5
    # ylabel!(plt[global_current], "Current (uA/cm2)")
    # plot!(plt[global_current], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium")
    # plot!(plt[global_current], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")
    plot!(plt[n_fig], xaxis = "Time (ms)", ticks = :native)

    return plt
end

function plot_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)

    # ----- INIT ----- #

    p_peaks = plot(xlabel=intra_axe_label, ylabel= "Peaks count (-)", title="peaks count")
    p_freqs = plot(xlabel=intra_axe_label, ylabel= "Frequence (Hz)", title="FI curve")
    p_height = plot(xlabel=intra_axe_label, ylabel= "Height (mV)", title="First peak height")
    p_width = plot(xlabel=intra_axe_label, ylabel= "width (ms)", title="First peak width")

    p_rheo = plot(xlabel=inter_axe_label, ylabel="rheobase (pA)")
    p_plan = plot(xlabel=intra_axe_label, ylabel=inter_axe_label, title="Heat map", legend=:topright, legendfontsize=7)#, yscale=:log10)
    p_pattern = plot(xlabel=intra_axe_label, ylabel=inter_axe_label, title="Pattern", yticks = (1:length(inter_labels), inter_labels), legend=:topright, legendfontsize=7)

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

        plot!(p_peaks, VEC_intra_parameter, VEC_peak_count      , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_freqs, VEC_intra_parameter, VEC_freq            , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        plot!(p_height, VEC_intra_parameter, VEC_first_peak_h   , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.7, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_width, VEC_intra_parameter, VEC_first_peak_w    , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.7, label=inter_label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        bar!(p_pattern, VEC_intra_parameter, fill(i+0.5, length(VEC_intra_parameter)), fillto=fill(i-0.45, length(VEC_intra_parameter)), 
                                                                        lw=0, linecolor=:match, bar_width=(VEC_intra_parameter[1]-VEC_intra_parameter[2])*1.05, label="", color=pattern_color)
    end

    # -------- Finish Ploting -------- #

    # --- rheobase barplot --- #
    bar!(p_rheo, inter_with_rheobase, rheobases, label="")
    annotate!(inter_with_rheobase, rheobases ./ 2, text.(string.(rheobases), :center, :center, :white, 7))

    # --- Pattern Plan (Heatmap) --- #
    number_pattern = length(pattern_list) - 1
    heatmap!(p_plan, VEC_intra_parameter, VEC_inter_parameter, M_pattern', clims = (-0.5, number_pattern + 0.5), colorbar=false, fillcolor = pattern_palette, interpolate=true)

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