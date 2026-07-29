export run_parameter_analyses, plot_parameter_analyses

function run_parameter_analyses(fp::FileParameters)

    # -------- amp vectors -------- #

    VEC_amp = 0.0:3.0:300.0

    println("")
    println("----------- Start Parameter Analyses -----------")
    println("With amps values : [$VEC_amp]")
    println("")

    @time results = parameter_analyses(VEC_amp, fp)
    println("------------ End Parameter Analyses ------------")

    return results
end

function plot_frequency_response(n_data::AnalyseData, pn_data::AnalyseData, VEC_amp, VEC_label, file_prefix)
    # [1,4,6,8,10,12,14] inhib
    # [1,3,5,7,9,11]
    # 1:length(VEC_label)
    take_idx = 1:1:length(VEC_label)

    L = length(take_idx)
    VEC_color = palette(:rainbow, L)
    size = (300, 200)

    n_M_freq       = n_data.M_freq
    n_M_pattern    = n_data.M_pattern
    pn_M_freq       = pn_data.M_freq
    pn_M_pattern    = pn_data.M_pattern

    plt = plot(xlabel="DRG Frequency (Hz)", ylabel= "DH Frequency (Hz)", size=size)
    plt_DRG = plot(xlabel="DRG stimulation (pA)", ylabel= "DRG Frequency (Hz)", size=size)
    plt_DH = plot(xlabel="DRG stimulation (pA)", ylabel= "DH Frequency (Hz)", size=size)

    j = 0
    for (i,(n_VEC_freq, n_VEC_pattern, pn_VEC_freq, pn_VEC_pattern, label)) in 
                        enumerate(zip(eachcol(n_M_freq), eachcol(n_M_pattern), eachcol(pn_M_freq), eachcol(pn_M_pattern), VEC_label))

        binary_value  = ifelse.(n_VEC_pattern .< 4, 0, 1)
        #binary_form  = markers_list[ ifelse.(n_VEC_pattern .< 4, 1, 5) ]

        VEC_afferent = n_VEC_freq[binary_value .== 1]
        VEC_response = pn_VEC_freq[binary_value .== 1 ]
        # VEC_afferent = n_VEC_freq .* binary_value
        # VEC_response = pn_VEC_freq .* binary_value

        if i in take_idx
            j += 1
            c = VEC_color[j]
            m_size = 1.5

            #label = "$(label) mV"
            plot!(plt, [], [], color=c, label=label)
            plot!(plt_DRG, [], [], color=c, label=label)
            plot!(plt_DH, [], [], color=c, label=label)

            plot!(plt , VEC_afferent, VEC_response, marker=:circle, markersize=m_size, linealpha=1.0, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)
            plot!(plt_DRG , VEC_amp, n_VEC_freq .* binary_value, marker=:circle, markersize=m_size, linealpha=1.0, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)
            plot!(plt_DH , VEC_amp, pn_VEC_freq .* binary_value, marker=:circle, markersize=m_size, linealpha=1.0, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)
        end
    end

    # savefig(plt, "plots/default/$(file_prefix)_response.pdf")
    savefig(plt_DRG, "plots/default/$(file_prefix)_DRG_freq.pdf")
    savefig(plt_DH, "plots/default/$(file_prefix)_DH_freq.pdf")

    return plt
end

function plot_data_analyse(data::AnalyseData, VEC_label, VEC_amp, inter_axe_label, file_prefix)
    # [1,4,6,8,10,12,14] inhib
    # [1,3,5,7,9,11]
    # 1:length(VEC_label)
    take_idx = 1:length(VEC_label)

    L = length(take_idx)
    VEC_color = palette(:rainbow, L)

    # ----- INIT PLOTS ----- #

    amp_label = "Stimulation (pA)"
    xticks = VEC_amp[1]:50:VEC_amp[end]
    
    p_peaks   = plot(xlabel=amp_label, ylabel= "Peak count (-)", xticks=xticks)
    p_freqs   = plot(xlabel=amp_label, ylabel= "Frequency (Hz)" , xticks=xticks) #, size = (500, 250))
    p_height  = plot(xlabel=amp_label, ylabel= "Height (mV)"    , xticks=xticks)
    p_width   = plot(xlabel=amp_label, ylabel= "Width (ms)"     , xticks=xticks)

    # v = L"m_{8,\infty}"
    # inter_axe_label = "Shift $v (mV)"
    p_rheo    = plot(xlabel=inter_axe_label, ylabel="rheobase (pA)", left_margin = 5mm, bottom_margin = 5mm, margin = 5mm
                                                                                                )#, size = (400, 200))

    p_pattern = plot(left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    #plot!(p_pattern, xtickfontsize = 8, xguidefontsize = 11, yguidefontsize = 9, size = (350, 175))
    plot!(p_pattern, xticks=xticks, xlabel=amp_label, ylabel=inter_axe_label, yticks = (1:length(take_idx), VEC_label[take_idx]))

    # Add color legend
    # plot!(p_pattern, legend=:topright, legendfontsize=7)
    # for (c, l) in zip(colors_list, pattern_list)
    #     scatter!(p_pattern, [], [], marker=:square, color = c, label = l, markersize = 4)
    # end
    
    # ----- Fill plots ----- #

    M_first_h = first.(data.M_first_peak_h_w)
    M_first_w = last.(data.M_first_peak_h_w)

    M_freq       = data.M_freq
    M_peak_count = data.M_peak_count
    M_pattern    = data.M_pattern

    j = 0
    for (i,(VEC_first_h, VEC_first_w, VEC_freq, VEC_peak_count, VEC_pattern, label)) in 
                        enumerate(zip(eachcol(M_first_h), eachcol(M_first_w), eachcol(M_freq), eachcol(M_peak_count), eachcol(M_pattern), VEC_label))

        pattern_form  = markers_list[VEC_pattern .+ 1]
        binary_form  = markers_list[ ifelse.(VEC_pattern .< 4, 1, 5) ]
        pattern_color = colors_list[VEC_pattern .+ 1]

        if i in take_idx
            j += 1
            c = VEC_color[j]
            m_size = 1.5

            #label = "$(label) mV"
            plot!(p_freqs, [], [], color=c, label=label)
        
            plot!(p_height, VEC_amp, VEC_first_h    , marker=:circle     , markersize=m_size, linealpha=0.6, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)
            plot!(p_width , VEC_amp, VEC_first_w    , marker=:circle     , markersize=m_size, linealpha=0.6, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)

            plot!(p_peaks , VEC_amp, VEC_peak_count , marker=binary_form, markersize=m_size, linealpha=1.0, markeralpha=0.9, label=label, markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)
            plot!(p_freqs , VEC_amp, VEC_freq , marker=binary_form, markersize=m_size, linealpha=1.0, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0, color = c)

            bar!(p_pattern, VEC_amp, fill(j+0.5, length(VEC_amp)), fillto=fill(j-0.45, length(VEC_amp)), 
                                                                            lw=0, linecolor=:match, bar_width=(VEC_amp[1]-VEC_amp[2])*1.05, label="", color=pattern_color)

        end
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

    # savefig(p_peaks, "plots/default/$(file_prefix)_peaks-curve.pdf")
    savefig(p_freqs, "plots/default/$(file_prefix)_F-I-curve.pdf")
    # savefig(p_height, "plots/default/$(file_prefix)_first_height.pdf")
    # savefig(p_width, "plots/default/$(file_prefix)_first_width.pdf")

    savefig(p_pattern, "plots/default/$(file_prefix)_pattern.pdf")
    # savefig(p_rheo, "plots/default/$(file_prefix)_rheobases.pdf")

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

    if !isnothing(results.projection_neuron) && !isnothing(results.nociceptor)
        plot_frequency_response(results.nociceptor, results.projection_neuron, VEC_amp, VEC_label, file_prefix)
    else
        println("(plot_parameter_analyses) No response")
    end

    return
end
