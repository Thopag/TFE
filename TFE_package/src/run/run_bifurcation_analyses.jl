export run_bifurcation_analyses, plot_bifurcation_analyses

function run_bifurcation_analyses(fp::FileParameters)

    # -------- bif Parameter -------- #

    lens_param = PropertyLens(:amp) ∘ PropertyLens(:stimulation)
    amp_min = -1320.0
    amp_max = 300.0

    println("")
    println("----------- Start Bifurcations -----------")
    results = bifurcation_analyses(fp, lens_param, amp_min, amp_max)
    println("------------ End Bifurcations ------------")

    return results
end

function add_plot_br(plt, i, br, label, dict_c_specialpoint, reds, greens, greys)

    plot!(plt, [], [], label=label, color=greys[i], alpha=1)

    # ----  Add result ---- #
    V =  [x[1] for x in br.branch.x]
    amps = br.branch.param
    stability = br.branch.stable

    color_stability = [reds[i], greens[i]]
    linestyle_stability = [:dash, :solid]

    start_idx = 1
    # Add special point and trajectories
    for specialpoint in br.specialpoint
        sp_idx = specialpoint.idx

        plot!(plt, amps[start_idx:sp_idx] , V[start_idx:sp_idx], c=color_stability[stability[start_idx] + 1], linestyle=linestyle_stability[stability[start_idx] + 1] 
                                                        ,alpha=0.7, label="", linewidth = 1.0)
        start_idx = sp_idx + 1

        symbol_type = specialpoint.type
        colors = get(dict_c_specialpoint, symbol_type, :blue)
        scatter!(plt, [amps[sp_idx]], [V[sp_idx]], label="", c=colors[i], markersize = 4, alpha=1)
    end
    return
end

function plot_bifurcation_analyses(results::BifurcationResults, analyse_r::Union{Nothing,AnalyseResults}, fp::FileParameters; file_prefix = "default")

    xlimits = :native
    xticks = :native
    VEC_label = fp.VEC_label
    VEC_br = results.VEC_br

    L = length(VEC_label)
    reds   = get_palette(L, :Reds, :red)
    greens = get_palette(L, :Greens, :green)
    greys  = get_palette(L, :Greys, :grey)

    if L > 1
        dict_c_specialpoint = Dict{Symbol, Vector{RGB{Float64}}}(:hopf => reds, :bp => greens, :endpoint => greys)
    else
        dict_c_specialpoint = Dict{Symbol, Vector{Symbol}}(:hopf => reds, :bp => greens, :endpoint => greys)
    end

    # init plot
    xticks = results.param_min:30:results.param_max
    plt = plot(xlabel="amp (pA)", ylabel=" Voltage (mV)", legendfontsize=7, legend = :bottomleft, xticks=xticks, xlims=xlimits)

    # add legend
    for ((symbol_type, colors), (_, label)) in zip(dict_c_specialpoint, label_bif_specialpoint)
        scatter!(plt, [], [], label=label, c=colors[(end ÷ 2) + 1])
    end

    for (i,(br, label)) in enumerate(zip(VEC_br, VEC_label))
        add_plot_br(plt, i, br, label, dict_c_specialpoint, reds, greens, greys)
    end

    if !isnothing(analyse_r)
        purples  = get_palette(L, :Purples, :purple)
        VEC_amp = analyse_r.VEC_amp
        M_first_peak_h_w = analyse_r.nociceptor.M_limit_cycle_min_max

        for (i,(VEC_min, VEC_max)) in enumerate(  zip( eachcol(first.(M_first_peak_h_w)), eachcol(last.(M_first_peak_h_w)) ) )
            plot!(plt, VEC_amp, VEC_min, color= purples[i], marker=:circle, markersize=2, linealpha=0.5, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0)
            plot!(plt, VEC_amp, VEC_max, color= purples[i], marker=:circle, markersize=2, linealpha=0.5, markeralpha=0.9, label="", markerstrokecolor = :match, markerstrokewidth = 0.0)
        end
    end

    savefig(plt, "plots/default/$(file_prefix)_bifurcation.pdf")

    return
end
