export run_frequency_plan, plot_frequency_plan

function run_frequency_plan(pp::PlanParameters)

    # -------- amp vectors -------- #

    VEC_amp = [50.0:10.0:90.0; 100.0:25.0:300.0]

    println("")
    println("----------- Start frequency Plan -----------")
    println("With amps values : [$(VEC_amp)]")
    println("")

    @time results = frequency_plan(VEC_amp, pp)
    println("------------ End frequency Plan ------------")

    return results
end

function plot_3D_plane(pp::PlanParameters, results::FrequencyPlanResults, data::FrequencyPlanData, exct_data::Union{Nothing,ExcitabilityPlanData}, file_prefix)

    spiking_filter = true

    cs = get(colorschemes[:rainbow], range(0.01, 0.99, length=256))
    cmap = cgrad(cs, 25, categorical = true)
    clip = :native #(0.0, 200.0)

    VEC_amp = results.VEC_amp

    VEC_row_param = pp.VEC_row_param
    VEC_col_param = pp.VEC_col_param

    row_label = pp.row_label
    col_label = pp.col_label

    # Accumulators for flat 1D vectors
    X_pts = Float64[]
    Y_pts = Float64[]
    Z_pts = Float64[]
    I_pts = Float64[]

    for (k,amp) in enumerate(VEC_amp)

        M_freq = data.VEC_M_freq[k]

        if !isnothing(exct_data) && spiking_filter
            M_spiking = exct_data.M_spiking
            filter = Int.(M_spiking .<= amp)
            M_freq = M_freq .* filter
        end
    
        for (i,x_i) in enumerate(VEC_col_param)
            for (j,y_j) in enumerate(VEC_row_param)
                push!(X_pts, x_i)
                push!(Y_pts, y_j)
                push!(Z_pts, amp)

                # Your 4th value (intensity) at (x_i, y_j, z_val)
                val = M_freq[j,i]
                push!(I_pts, val)
            end
        end
    end

    # Single 3D scatter plot
    plt = scatter(
        X_pts, Y_pts, Z_pts,
        marker_z = I_pts,       # Color by intensity
        color = cmap,
        markersize = 4,
        markerstrokewidth = 1,
        alpha = 0.5,
        clim=clip,
        xlabel=col_label, ylabel=row_label, zlabel="DRG stimulation (pA)",
        label="",
        camera=(30,30)
    )
    display(plt)
end

function plot_data_frequency_plan(pp::PlanParameters, results::FrequencyPlanResults, data::FrequencyPlanData, exct_data::Union{Nothing,ExcitabilityPlanData}, file_prefix)

    reverse = true
    spiking_filter = true
    with_lido_traj = true

    if spiking_filter
        if !isnothing(exct_data)
            M_spiking = exct_data.M_spiking
        else
            println("NO exct_data")
        end
    end

    VEC_amp = results.VEC_amp

    # [1,4,6,8,10,12,14] inhib
    # [1,3,5,7,9,11]
    # 1:length(VEC_amp)
    take_idx = [8]
    
    cs = get(colorschemes[:rainbow], range(0.01, 0.99, length=256))
    cmap = cgrad(cs, 25, categorical = false)
    clip = (0.0, 225.0)
    m = 400
    size = (1.05 * m, m)

    VEC_row_param = pp.VEC_row_param
    VEC_col_param = pp.VEC_col_param

    row_label = pp.row_label
    col_label = pp.col_label

    if reverse
        VEC_row_param = pp.VEC_col_param 
        VEC_col_param = pp.VEC_row_param

        row_label = pp.col_label 
        col_label = pp.row_label
        
        # var = L"h_{8, \infty}"
        # var2 = L"m_{8, \infty}"
        # row_label = "Shift 40% $(var) and 60% $(var2) (mV)"
    end

    for (i,amp) in enumerate(VEC_amp)

        if i in take_idx
            # ---------- get matrices ---------- #

            M_freq = data.VEC_M_freq[i]

            if !isnothing(exct_data) && spiking_filter
                filter = ifelse.(M_spiking .<= amp, true, false)
            end

            if reverse
                M_freq = transpose(M_freq)
            end

            # ---------- make heatmap ---------- #

            diff_x = abs(VEC_col_param[2]-VEC_col_param[1])
            diff_y = abs(VEC_row_param[2]-VEC_row_param[1])

            x_limits = (VEC_col_param[1] -diff_x/8, VEC_col_param[end] + diff_x/8)
            y_limits = (VEC_row_param[1] -diff_y/8, VEC_row_param[end] + diff_y/8)

            plt_freq = plot(xlabel=col_label, ylabel=row_label, size=size)
            title!(plt_freq, "$amp pA")

            heatmap!(plt_freq, VEC_col_param, VEC_row_param, M_freq, background_color_inside = :black, c = cmap, clims=clip)

            plot!(plt_freq, xlims=x_limits, ylims=y_limits)

            ################### spiking region ###################

            if !isnothing(exct_data) && spiking_filter
                if reverse
                    filter = transpose(filter)
                end
                contour!(plt_freq, VEC_col_param, VEC_row_param, filter, levels = [0.5], color = :white, linewidth = 3)
            end

            ################### Lido Traj ###################
            if with_lido_traj
                add_lido_shift_inhib_traj(plt_freq)
            end

            # ---------- save figures ---------- #

            savefig(plt_freq, "plots/default/$(file_prefix)_freq_plan_$(amp)pA.svg")
        end
    end
end

function plot_frequency_plan(pp::PlanParameters, results::FrequencyPlanResults, exct_result::Union{Nothing, ExcitabilityPlanResults}; file_prefix = "default")

    if !isnothing(results.nociceptor)
        if !isnothing(exct_result)
            n_exct_result = exct_result.nociceptor
        else
            n_exct_result = nothing
        end
        plot_data_frequency_plan(pp, results, results.nociceptor, n_exct_result, "$(file_prefix)_nociceptor")
        #plot_3D_plane(pp, results, results.nociceptor, n_exct_result, "$(file_prefix)_pn_3D_plane")
    else
        println("(plot_frequency_plan) No nociceptor")
    end

    if !isnothing(results.projection_neuron)
        if !isnothing(exct_result)
            pn_exct_result = exct_result.projection_neuron
        else
            pn_exct_result = nothing
        end
        plot_data_frequency_plan(pp, results, results.projection_neuron, n_exct_result, "$(file_prefix)_projection_neuron")
        #plot_3D_plane(pp, results, results.projection_neuron, pn_exct_result, "$(file_prefix)_pn_3D_plane")
    else
        println("(plot_frequency_plan) No projection neuron")
    end

    return
end