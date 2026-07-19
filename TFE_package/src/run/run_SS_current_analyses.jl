export run_SS_current_analyses, plot_SS_current_analyses

function run_SS_current_analyses(fp::FileParameters)

    V = -120.0:0.5:60.0

    println("")
    results = SS_current_analyses(V, fp)
    println("-------------- SS Currents Done --------------")
    return results
end

function plot_SS_current_analyses(results::SSCurrentResults, fp::FileParameters; file_prefix = "default")

    xticks = [-120, -90, -60, -30, 0, 30, 60]
    n_ylimits =  :native
    pn_ylimits =  :native

    p_n = plot(xlabel=L"Voltage ($mV$)", ylabel= L"Steady State Current ($\mu A/cm^2$)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks, ylims=n_ylimits)

    p_pn = plot(xlabel=L"Voltage ($mV$)", ylabel= L"Steady State Current ($\mu A/cm^2$)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks, ylims=pn_ylimits)

    V = results.V
    for (n_current, pn_current, label) in zip(results.VEC_nociceptor, results.VEC_projection_neuron, fp.VEC_label)

        #plot!(p_pn, V, pn_current.INa, label="INa")
        #plot!(p_pn, V, pn_current.IK_dr, label="IK_dr")

        plot!(p_pn, V, pn_current.ICa_Ls, label="ICa_Ls")
        #plot!(p_pn, V, pn_current.IK_ir, label="IK_ir")
        #plot!(p_pn, V, pn_current.IK_M, label="IK_M")

    end
    # --- save --- #

    # savefig(p_n, "plots/default/$(file_prefix)_SS_current_n.pdf")
    # savefig(p_pn, "plots/default/$(file_prefix)_SS_current_pn.pdf")

    return p_n, p_pn
end