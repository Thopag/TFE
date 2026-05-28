############################ PARAMETER SET TYPE ############################
parameter_set = "DIV7"
############################ PARAMETER SET TYPE ############################

if parameter_set == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif parameter_set == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    cs = get(colorschemes[:nipy_spectral], range(0.15, 0.97, length=256))
    cmap = cgrad(cs, 25, categorical = true, rev = true, scale = :exp)

    u0 = get_u0()
    amps = 0.0:2:300.0
    amps = vcat(0.0:2:32.0, vcat(35.0:5:45.0, 50.0:50.0:300.0))

    with_lido_traj = true

    # -------- Vectors -------- #

    shifts = vcat(0:0.5:4, 5.0:5:25.0) #0:1:25.0
    inhibs = vcat(0:0.03:0.18, 0.2:0.2:1.0)
    g_1p7 = 0.0:5.0:100.0
    g_1p3 = 0.0:0.05:1.0

    # -------- First Parameter -------- #

    VEC_first_param = shifts
    first_param_label = "Shift NaV1.7 (mV)"

    # -------- Second Parameter -------- #

    VEC_second_param = inhibs
    second_param_label = "Inhibition NaV1.7 (-)"


    # -------- General Labeling -------- #

    folder_name = "default"
    #file_prefix = "$(parameter_set)_$(TFE.shift_inact_1p7)-inact-1.7_$(TFE.shift_inact_1p3)-inact-1.3_$(TFE.shift_inact_1p8)-inact-1.8_$(TFE.shift_act_1p8)-act-1.8"
    file_prefix = "DIV7_g1.7_60-g1.3_0.35"

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Will be stored in $folder_name")
    println("Parameter set type : $parameter_set")
    println("lidocaine effect :")
    println(lidocaine_effect_setup())
    println("")
    println("INTRA simulations parameter is [$first_param_label]")
    println("   with values : $VEC_first_param")
    println("")
    println("INTER simulations parameter is [$second_param_label]")
    println("   with values : $VEC_second_param")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

    # -------- initiations -------- #

    n_row = length(VEC_first_param)
    n_col = length(VEC_second_param)

    M_rheobase = Matrix{Float32}(undef, n_row, n_col)
    M_spiking = Matrix{Float32}(undef, n_row, n_col)

    # -------- Parameter looping -------- #

    println("################ Start Looping ################ ")
    for (i,first_param) in enumerate(VEC_first_param)
        println("__________________________")
        println("First Loop value : $first_param -- $(round(((i-1)/n_row*100), digits=2)) %")
        println("--------------------------")
        for (j,second_param) in enumerate(VEC_second_param)

            println("Second Loop value : $second_param -- $(round(((j-1)/n_col*100), digits=2)) %")

            # -------- iterations -------- #
            param_function(amp) = get_param(amp;
            #"""###################### PARAMETER ######################"""#  
                        C_lidocaine=first_param,
                        g_nav1p7 = 60.0 * (1-second_param),
                        g_nav1p3 = 0.35,
                        )
            #"""#######################################################"""#
            
            rheobase, spiking = find_rheobase(param_function, amps, u0)
            M_rheobase[i, j] = rheobase
            M_spiking[i, j] = spiking
        end
    end

    println("################ End Looping ################ ")

    # ---------- make heatmap ---------- #

    diff_x = VEC_second_param[2]-VEC_second_param[1]
    diff_y = VEC_first_param[2]-VEC_first_param[1]

    x_limits = (-diff_x/8, VEC_second_param[end] + diff_x/8)
    y_limits = (-diff_y/8, VEC_first_param[end] + diff_y/8)

    plt_rheobase = plot(xlabel=second_param_label, ylabel=first_param_label)
    plt_spiking = plot(xlabel=second_param_label, ylabel=first_param_label)

    heatmap!(plt_rheobase, VEC_second_param, VEC_first_param, M_rheobase, background_color_inside = :black, c = cmap, clims=(amps[1],amps[end]))
    heatmap!(plt_spiking, VEC_second_param, VEC_first_param, M_spiking, background_color_inside = :black, c = cmap, clims=(amps[1],amps[end]))

    plot!(plt_rheobase, xlims=x_limits, ylims=y_limits)
    plot!(plt_spiking, xlims=x_limits, ylims=y_limits)

    ################### Lido Traj ###################
    if with_lido_traj
        TFE.add_lido_shift_inhib_traj(plt_rheobase)
        TFE.add_lido_shift_inhib_traj(plt_spiking)
    end

    # ---------- save figures ---------- #

    jldsave("plots/$(folder_name)/$(file_prefix)_plan.jld2"; M_rheobase, M_spiking, VEC_first_param, VEC_second_param)

    savefig(plt_rheobase, "plots/$(folder_name)/$(file_prefix)_rheobase_plan.pdf")
    savefig(plt_spiking, "plots/$(folder_name)/$(file_prefix)_spiking_plan.pdf")
end

main()