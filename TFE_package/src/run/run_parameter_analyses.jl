export run_parameter_analyses, plot_parameter_analyses

function run_parameter_analyses(fp::FileParameters)

    # -------- amp vectors -------- #

    VEC_amp = 0.0:20:300.0

    with_nociceptor = true
    with_projection_neuron = true

    println("")
    println("----------- Start Parameter Analyses -----------")
    println("With amps values : [$VEC_amp]")
    println("Nociceptor is [$with_nociceptor] and projection neuron is [$with_projection_neuron]")
    println("")

    @time results = parameter_analyses(VEC_amp, fp; with_nociceptor=with_nociceptor, with_projection_neuron=with_projection_neuron)
    println("------------ End Parameter Analyses ------------")

    return results
end

function plot_data_analyse(data::AnalyseData, VEC_label, VEC_amp, inter_axe_label, file_prefix)

    # ----- INIT PLOTS ----- #

    amp_label = "Amp (pA)"
    xticks = VEC_amp[1]:30:VEC_amp[end]
    
    p_peaks   = plot(xlabel=amp_label, ylabel= "Peaks count (-)", xticks=xticks)
    p_freqs   = plot(xlabel=amp_label, ylabel= "Frequence (Hz)" , xticks=xticks)
    p_height  = plot(xlabel=amp_label, ylabel= "Height (mV)"    , xticks=xticks)
    p_width   = plot(xlabel=amp_label, ylabel= "width (ms)"     , xticks=xticks)

    p_rheo    = plot(xlabel=inter_axe_label, ylabel="rheobase (pA)")
    p_pattern = plot(xlabel=amp_label, ylabel=inter_axe_label, yticks = (1:length(VEC_label), VEC_label), xticks=xticks, legend=:topright, legendfontsize=7)

    # Add color legend
    for (c, l) in zip(colors_list, pattern_list)
        scatter!(p_pattern, [], [], marker=:square, color = c, label = l, markersize = 4)
    end
    
    # ----- Fill plots ----- #

    M_first_h = first.(data.M_first_peak_h_w)
    M_first_w = last.(data.M_first_peak_h_w)

    M_freq       = data.M_freq
    M_peak_count = data.M_peak_count
    M_pattern    = data.M_pattern

    for (i,(VEC_first_h, VEC_first_w, VEC_freq, VEC_peak_count, VEC_pattern, label)) in 
                        enumerate(zip(eachcol(M_first_h), eachcol(M_first_w), eachcol(M_freq), eachcol(M_peak_count), eachcol(M_pattern), VEC_label))

        pattern_form  = markers_list[VEC_pattern .+ 1]
        pattern_color = colors_list[VEC_pattern .+ 1]

        plot!(p_height, VEC_amp, VEC_first_h    , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_width , VEC_amp, VEC_first_w    , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        plot!(p_peaks , VEC_amp, VEC_peak_count , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0)
        plot!(p_freqs , VEC_amp, VEC_freq       , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0)

        bar!(p_pattern, VEC_amp, fill(i+0.5, length(VEC_amp)), fillto=fill(i-0.45, length(VEC_amp)), 
                                                                        lw=0, linecolor=:match, bar_width=(VEC_amp[1]-VEC_amp[2])*1.05, label="", color=pattern_color)
    end

    # -------- Finish Ploting -------- #

    # --- first peak height --- #
    hline!(p_height, [0.0], color=:red, linestyle = :dash, label="")

    # --- rheobase barplot --- #
    VEC_rheobase = data.VEC_rheobase
    not_nothing_idx = .!isnothing.(VEC_rheobase)

    labels_not_nothing = VEC_label[not_nothing_idx]
    bars_not_nothing = VEC_rheobase[not_nothing_idx]
    
    bar!(p_rheo, labels_not_nothing, bars_not_nothing, label="")
    annotate!(labels_not_nothing, bars_not_nothing ./ 2, text.(string.(bars_not_nothing), :center, :center, :white, 7))

    # --- save --- #

    savefig(p_peaks, "plots/default/$(file_prefix)_peaks-curve.pdf")
    savefig(p_freqs, "plots/default/$(file_prefix)_F-I-curve.pdf")
    savefig(p_height, "plots/default/$(file_prefix)_first_height.pdf")
    savefig(p_width, "plots/default/$(file_prefix)_first_width.pdf")

    savefig(p_pattern, "plots/default/$(file_prefix)_pattern.pdf")
    savefig(p_rheo, "plots/default/$(file_prefix)_rheobases.pdf")

    return p_peaks, p_freqs, p_height, p_width, p_rheo, p_pattern
    
end

function plot_parameter_analyses(results::AnalyseResults, fp::FileParameters; file_prefix = "default")

    
    VEC_label = fp.VEC_label
    inter_axe_label = fp.parameter_label

    VEC_amp = results.VEC_amp

    if !isnothing(results.nociceptor)
        plot_data_analyse(results.nociceptor, VEC_label, VEC_amp, inter_axe_label, "$(file_prefix)_nociceptor")
    else
        println("(plot_parameter_analyses) No nociceptor")
    end

    if !isnothing(results.projection_neuron)
        plot_data_analyse(results.projection_neuron, VEC_label, VEC_amp, inter_axe_label, "$(file_prefix)_projection_neuron")
    else
        println("(plot_parameter_analyses) No projection neuron")
    end

    return
end
