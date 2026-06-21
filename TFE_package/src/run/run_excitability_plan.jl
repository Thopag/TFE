export run_excitability_plan, plot_excitability_plan

function run_excitability_plan(u0, nociceptor_parameter, p_stim, duration)

    # -------- amp vectors -------- #

    VEC_amp = [0.0:1:49.0; 50.0:5:95.0; 100.0:25:300.0]

    # -------- Row Parameter -------- #

    inhibs = 0:0.5:1.0

    VEC_row_param = inhibs
    row_label = "inhibition NaV1.8 (-)"

    # -------- Col Parameter -------- #

    inhibs = 0:0.5:1.0

    VEC_col_param = inhibs
    col_label = "inhibition NaV1.7 (-)"

    # -------- Create matrix -------- #

    M_p_noci = [nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0 - r),
                                        g_NaV1p7 = 3.0 * (1.0 - c) ) for r in VEC_row_param, c in VEC_col_param]

    M_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n) for n in M_p_noci]

    println("")
    println("----------- Start Excitability Plan -----------")
    println("With amps values : [$VEC_amp]")
    println("With row values : [$VEC_row_param]")
    println("With col values : [$VEC_col_param]")
    println("")

    @time results = excitability_plan(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, duration, u0)
    println("------------ End Excitability Plan ------------")

    return results
end

function plot_excitability_plan(results::ExcitabilityPlanResults; file_prefix = "default")

    cs = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap = cgrad(cs, 25, categorical = true, rev = true, scale = :exp)

    with_lido_traj = false

    # ---------- get matrices ---------- #

    VEC_row_param = results.VEC_row_param
    VEC_col_param = results.VEC_col_param

    row_label = results.row_label
    col_label = results.col_label

    VEC_amp = results.VEC_amp

    M_rheobase = results.M_rheobase
    M_spiking = results.M_spiking

    # ---------- make heatmap ---------- #

    diff_x = VEC_col_param[2]-VEC_col_param[1]
    diff_y = VEC_row_param[2]-VEC_row_param[1]

    x_limits = (-diff_x/8, VEC_col_param[end] + diff_x/8)
    y_limits = (-diff_y/8, VEC_row_param[end] + diff_y/8)

    plt_rheobase = plot(xlabel=col_label, ylabel=row_label)
    plt_spiking = plot(xlabel=col_label, ylabel=row_label)

    heatmap!(plt_rheobase, VEC_col_param, VEC_row_param, M_rheobase, background_color_inside = :black, c = cmap, clims=(VEC_amp[1],VEC_amp[end]))
    heatmap!(plt_spiking , VEC_col_param, VEC_row_param, M_spiking , background_color_inside = :black, c = cmap, clims=(VEC_amp[1],VEC_amp[end]))

    plot!(plt_rheobase, xlims=x_limits, ylims=y_limits)
    plot!(plt_spiking , xlims=x_limits, ylims=y_limits)

    ################### Lido Traj ###################
    if with_lido_traj
        add_lido_shift_inhib_traj(plt_rheobase)
        add_lido_shift_inhib_traj(plt_spiking)
    end

    # ---------- save figures ---------- #

    savefig(plt_rheobase, "plots/default/$(file_prefix)_rheobase_plan.pdf")
    savefig(plt_spiking, "plots/default/$(file_prefix)_spiking_plan.pdf")
    return
end