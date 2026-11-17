export run_frequency_plan, plot_frequency_plan

function run_frequency_plan(f_2D::File2D)

    # -------- amp vectors -------- #

    VEC_amp = [200.0] #[10.0:10.0:40.0; 50.0:25.0:125.0; 150.0:50.0:300.0]

    println("")
    println("----------- Start frequency Plan -----------")
    println("With amps values : [$(VEC_amp)]")
    println("")

    @time results = frequency_plan(VEC_amp, f_2D)
    println("------------ End frequency Plan ------------")

    return results
end

function plot_data_frequency_plan(f_2D::File2D, results::FrequencyPlanResults, data::FrequencyPlanData, file_prefix)

    VEC_amp = results.VEC_amp

    take_idx = 1:length(VEC_amp)

    show_pattern_region = true
    with_lido_traj = false

    # axis
    x_values = f_2D.VEC_col_param
    y_values = f_2D.VEC_row_param

    x_label = f_2D.col_label
    y_label = f_2D.row_label

    # colorbar
    cs = get(colorschemes[:darkrainbow], range(0.01, 0.99, length=256))
    cmap = cgrad(cs, 25, categorical = false)
    clip = :native

    for (i,amp) in enumerate(VEC_amp)

        if i in take_idx

            M_init_freq = data.VEC_M_init_freq[i]
            plt_init_freq = make_heatmap(M_init_freq, x_values, y_values, x_label, y_label, clip, cmap)

            M_sust_freq = data.VEC_M_sust_freq[i]
            plt_sust_freq = make_heatmap(M_sust_freq, x_values, y_values, x_label, y_label, clip, cmap)

            M_pattern = data.VEC_M_pattern[i]
            # replace the -1 by missing
            M_masked = replace(M_pattern, -1 => missing)
            plt_pattern = make_heatmap(M_masked, x_values, y_values, x_label, y_label, (0, 3), pattern_palette)

            # Pattern region
            if show_pattern_region
                filter = ifelse.(M_pattern .== 3, true, false)
                contour!(plt_init_freq, x_values, y_values, filter, levels = [0.5], color = :white, linewidth = 3)
                contour!(plt_sust_freq, x_values, y_values, filter, levels = [0.5], color = :white, linewidth = 3)
            end

            # Lido Traj
            if with_lido_traj
                add_lido_shift_inhib_traj(plt_freq)
            end

            # ---------- save figures ---------- #

            savefig(plt_init_freq, "plots/default/$(file_prefix)_init_freq_plan_$(amp)pA.svg")
            savefig(plt_sust_freq, "plots/default/$(file_prefix)_sust_freq_plan_$(amp)pA.svg")
            savefig(plt_pattern, "plots/default/$(file_prefix)_pattern_plan_$(amp)pA.svg")
        end
    end
end

function plot_frequency_plan(f_2D::File2D, results::FrequencyPlanResults; file_prefix = "default")

    if !isnothing(results.nociceptor)
        plot_data_frequency_plan(f_2D, results, results.nociceptor,"$(file_prefix)_nociceptor")
    else
        println("(plot_frequency_plan) No nociceptor")
    end

    # if !isnothing(results.projection_neuron)
    #     plot_data_frequency_plan(f_2D, results, results.projection_neuron, "$(file_prefix)_projection_neuron")
    # else
    #     println("(plot_frequency_plan) No projection neuron")
    # end

    return
end