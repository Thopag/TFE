export run_current_plan, plot_current_plan
# max_val = maximum(x for x in vec if !isnan(x))

function run_current_plan(f_2D::File2D)

    # -------- amp vectors -------- #

    VEC_amp = 0.0:1:300.0

    println("")
    println("----------- Start Excitability Plan -----------")
    println("With amps values : [$VEC_amp]")
    println("")

    @time results = current_plan(VEC_amp, f_2D)
    println("------------ End Excitability Plan ------------")

    return results
end

function plot_data_current_plan(f_2D::File2D, results::CurrentPlanResults, data::CurrentPlanData, file_prefix)

    with_lido_traj = false
    # VEC_amp = results.VEC_amp

    # axis
    x_values = f_2D.VEC_col_param
    y_values = f_2D.VEC_row_param

    x_label = f_2D.col_label
    y_label = f_2D.row_label

    # -- rheobase heatmap -- #
    cs_rheo = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap_rheo = cgrad(cs_rheo, 25, categorical = false, rev = true)
    clip_rheo = (0.0, 100.0)

    plt_rheobase = make_heatmap(data.M_rheobase, x_values, y_values, x_label, y_label, clip_rheo, cmap_rheo)

    # -- spiking heatmap -- #
    cs_spiking = get(colorschemes[:rainbow1], range(0.0, 1.0, length=256))
    cmap_spiking = cgrad(cs_spiking, 25, categorical = false, rev = true)
    clip_spiking = (0.0, 300.0)
    
    plt_spiking = make_heatmap(data.M_spiking, x_values, y_values, x_label, y_label, clip_spiking, cmap_spiking)

    # -- first spike h heatmap -- #
    cs_rheo_h = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap_rheo_h = cgrad(cs_rheo_h, 25, categorical = false, rev = true)
    clip_rheo_h = :native

    plt_rheo_h = make_heatmap(data.M_rheo_h, x_values, y_values, x_label, y_label, clip_rheo_h, cmap_rheo_h)

    # -- first spike w heatmap -- #
    cs_rheo_w = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap_rheo_w = cgrad(cs_rheo_w, 25, categorical = false, rev = true)
    clip_rheo_w = :native

    plt_rheo_w = make_heatmap(data.M_rheo_w, x_values, y_values, x_label, y_label, clip_rheo_w, cmap_rheo_w)

    # Lido Traj
    if with_lido_traj
        add_lido_shift_inhib_traj(plt_rheobase)
        add_lido_shift_inhib_traj(plt_spiking)
    end

    # ---------- save figures ---------- #

    savefig(plt_rheobase, "plots/default/$(file_prefix)_rheobase_plan.svg")
    savefig(plt_spiking, "plots/default/$(file_prefix)_spiking_plan.svg")
    savefig(plt_rheo_h, "plots/default/$(file_prefix)_rheo_height_plan.svg")
    savefig(plt_rheo_w, "plots/default/$(file_prefix)_rheo_width_plan.svg")
end

function plot_current_plan(f_2D::File2D, results::CurrentPlanResults; file_prefix = "default")

    if !isnothing(results.nociceptor)
        plot_data_current_plan(f_2D, results, results.nociceptor, "$(file_prefix)_nociceptor")
    else
        println("(plot_current_plan) No nociceptor")
    end

    # if !isnothing(results.projection_neuron)
    #     plot_data_current_plan(f_2D, results, results.projection_neuron, "$(file_prefix)_projection_neuron")
    # else
    #     println("(plot_current_plan) No projection neuron")
    # end

    return
end