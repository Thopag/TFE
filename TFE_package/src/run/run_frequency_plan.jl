export run_frequency_plan, plot_frequency_plan

function run_frequency_plan(pp::PlanParameters)

    # -------- amp vectors -------- #

    VEC_amp = [75.0, 150.0]
    
    println("")
    println("----------- Start frequency Plan -----------")
    println("With amps values : [$(VEC_amp)]")
    println("")

    @time results = frequency_plan(VEC_amp, pp)
    println("------------ End frequency Plan ------------")

    return results
end

function plot_data_frequency_plan(pp::PlanParameters, results::FrequencyPlanResults, data::FrequencyPlanData, file_prefix; with_lido_traj=false)
    
    cs = get(colorschemes[:rainbow], range(0.01, 0.99, length=256))
    cmap = cgrad(cs, 25, categorical = true)

    VEC_amp = results.VEC_amp

    for (i,amp) in enumerate(VEC_amp)
        # ---------- get matrices ---------- #

        VEC_row_param = pp.VEC_row_param
        VEC_col_param = pp.VEC_col_param

        row_label = pp.row_label
        col_label = pp.col_label

        M_freq = data.VEC_M_freq[i]

        # ---------- make heatmap ---------- #

        diff_x = VEC_col_param[2]-VEC_col_param[1]
        diff_y = VEC_row_param[2]-VEC_row_param[1]

        x_limits = (-diff_x/8, VEC_col_param[end] + diff_x/8)
        y_limits = (-diff_y/8, VEC_row_param[end] + diff_y/8)

        plt_freq = plot(xlabel=col_label, ylabel=row_label)
        title!(plt_freq, "$amp pA")

        heatmap!(plt_freq, VEC_col_param, VEC_row_param, M_freq, background_color_inside = :black, c = cmap, clims=(0.0,200.0))

        plot!(plt_freq, xlims=x_limits, ylims=y_limits)

        ################### Lido Traj ###################
        if with_lido_traj
            add_lido_shift_inhib_traj(plt_freq)
        end

        # ---------- save figures ---------- #

        savefig(plt_freq, "plots/default/$(file_prefix)_freq_plan_$(amp)pA.pdf")
    end
end

function plot_frequency_plan(pp::PlanParameters, results::FrequencyPlanResults; file_prefix = "default")

    with_lido_traj = false

    if !isnothing(results.nociceptor)
        plot_data_frequency_plan(pp, results, results.nociceptor, "$(file_prefix)_nociceptor"; with_lido_traj=with_lido_traj)
    else
        println("(plot_frequency_plan) No nociceptor")
    end

    if !isnothing(results.projection_neuron)
        plot_data_frequency_plan(pp, results, results.projection_neuron, "$(file_prefix)_projection_neuron"; with_lido_traj=with_lido_traj)
    else
        println("(plot_frequency_plan) No projection neuron")
    end

    return
end