export run_SS_current_analyses, plot_SS_current_analyses

function run_SS_current_analyses(fp::FileParameters)

    V = -120.0:0.5:60.0

    println("")
    results = SS_current_analyses(V, fp)
    println("-------------- SS Currents Done --------------")
    return results
end

function plot_SS_current_analyses(results::SSCurrentResults, fp::FileParameters; file_prefix = "default")

    VEC_label = fp.VEC_label

    # [1,4,6,8,10,12,14] inhib
    # [1,3,5,7,9,11]
    # 1:length(VEC_label)
    take_idx = 1:length(VEC_label)
    L = length(take_idx)

    xticks = [-120, -90, -60, -30, 0, 30, 60]

    p_n = plot(xlabel="Voltage (mV)", ylabel= "Normed Availability (-)", legendfontsize=8, legend=:right, xticks = xticks)
    p_pn = plot(xlabel="Voltage (mV)", ylabel= "Steady State Current (µA/cm2)", legendfontsize=9, legend=:right, xticks = xticks)
    p_n = plot!(p_n, size=(300, 225), left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)

    V = results.V
    n_current_default = results.VEC_nociceptor[take_idx[1]]
    norm = maximum( abs.(n_current_default.INaV1p7))

    ytick = []
    j = 0
    VEC_color = palette(:rainbow, L)
    VEC_color = get_palette(L, :Reds, :red; dark=0.95, light=0.4)
    for (i,(n_current, pn_current, label)) in enumerate(zip(results.VEC_nociceptor, results.VEC_projection_neuron, fp.VEC_label))

        if i in take_idx
            j += 1
            label = "$(label) mV"
            y = abs.(n_current.INaV1p7) ./ norm
            plot!(p_n, V, y, color=VEC_color[j], label=label)

            if maximum(y) > 0.05
                push!(ytick, round(maximum(y), digits=2))
            end
        end
    end

    plot!(p_n, yticks = ytick)

    # --- save --- #

    savefig(p_n, "plots/default/$(file_prefix)_SS_current_n.pdf")
    savefig(p_pn, "plots/default/$(file_prefix)_SS_current_pn.pdf")

    return p_n, p_pn
end