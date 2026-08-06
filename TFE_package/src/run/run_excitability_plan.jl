export run_excitability_plan, plot_excitability_plan
# max_val = maximum(x for x in vec if !isnan(x))

function run_excitability_plan(pp::PlanParameters)

    # -------- amp vectors -------- #

    VEC_amp = [0.0:1:14.0; 15.0:2.5:47.5; 50.0:5:95.0; 100.0:25:300.0]

    println("")
    println("----------- Start Excitability Plan -----------")
    println("With amps values : [$VEC_amp]")
    println("")

    @time results = excitability_plan(VEC_amp, pp)
    println("------------ End Excitability Plan ------------")

    return results
end

function plot_data_excitability_plan(pp::PlanParameters, results::ExcitabilityPlanResults, data::ExcitabilityPlanData, file_prefix)
    
    reverse = true
    with_lido_traj = true

    cs = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap = cgrad(cs, 25, categorical = false, rev = true) #, scale = :exp)

    # ---------- get matrices ---------- #

    VEC_row_param = pp.VEC_row_param
    VEC_col_param = pp.VEC_col_param

    row_label = pp.row_label
    col_label = pp.col_label

    VEC_amp = results.VEC_amp
    clip = (VEC_amp[1],VEC_amp[end])
    clip = (0.0,100)
    m = 400
    size = ( 1.05 * m, m)

    M_rheobase = data.M_rheobase
    M_spiking = data.M_spiking

    if reverse
        VEC_row_param = pp.VEC_col_param 
        VEC_col_param = pp.VEC_row_param

        row_label = pp.col_label 
        col_label = pp.row_label

        # var = L"h_{8, \infty}"
        # var2 = L"m_{8, \infty}"
        # row_label = "Shift 40% $(var) and 60% $(var2) (mV)"

        VEC_amp = results.VEC_amp

        M_rheobase = transpose(data.M_rheobase)
        M_spiking = transpose(data.M_spiking)
    end

    # ---------- make heatmap ---------- #

    diff_x = abs(VEC_col_param[2]-VEC_col_param[1])
    diff_y = abs(VEC_row_param[2]-VEC_row_param[1])

    x_limits = (VEC_col_param[1] -diff_x/8, VEC_col_param[end] + diff_x/8)
    y_limits = (VEC_row_param[1] -diff_y/8, VEC_row_param[end] + diff_y/8)

    plt_rheobase = plot(title="rheobase", xlabel=col_label, ylabel=row_label, size=size)
    plt_spiking = plot(title="spiking", xlabel=col_label, ylabel=row_label, size=size)

    heatmap!(plt_rheobase, VEC_col_param, VEC_row_param, M_rheobase, background_color_inside = :black, c = cmap, clims=clip)
    heatmap!(plt_spiking , VEC_col_param, VEC_row_param, M_spiking , background_color_inside = :black, c = cmap, clims=clip)

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
end

function plot_excitability_plan(pp::PlanParameters, results::ExcitabilityPlanResults; file_prefix = "default")

    if !isnothing(results.nociceptor)
        #plot_data_excitability_plan(pp, results, results.nociceptor, "$(file_prefix)_nociceptor")
    else
        println("(plot_excitability_plan) No nociceptor")
    end

    if !isnothing(results.projection_neuron)
        #plot_data_excitability_plan(pp, results, results.projection_neuron, "$(file_prefix)_projection_neuron")
    else
        println("(plot_excitability_plan) No projection neuron")
    end

    return
end