############################ PARAMETER SET TYPE ############################
parameter_set = "DIV0"
############################ PARAMETER SET TYPE ############################

if parameter_set == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif parameter_set == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    cs = get(colorschemes[:nipy_spectral], range(0.15, 1.0, length=256))
    cmap = cgrad(cs, 25, categorical = true, rev = true, scale = :exp)

    u0 = get_u0()
    amps = 0.0:50.0:300.0

    # -------- Vectors -------- #

    shifts = 0:7.5:15.0
    inhibs = 0.0:0.5:1.0 #vcat(0:0.45:0.9, 0.92:0.04:1.0)

    # -------- First Parameter -------- #

    VEC_first_param = shifts
    first_param_label = "Shift (mV)"

    # -------- Second Parameter -------- #

    VEC_second_param = inhibs
    second_param_label = "Inhibition (-)"


    # -------- General Labeling -------- #

    folder_name = "default"
    file_prefix = "$(parameter_set)"

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

    M_rheobase = Matrix{Union{NaN, Float32}}(undef, n_row, n_col)
    M_spiking = Matrix{Union{NaN, Float32}}(undef, n_row, n_col)

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
                        g_nav1p8 = 30.0 * (1-second_param),
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

    heatmap!(plt_rheobase, VEC_second_param, VEC_first_param, M_rheobase, nan_color=:black, c = cmap, climb=(amps[1],amps[end]))
    heatmap!(plt_spiking, VEC_second_param, VEC_first_param, M_spiking, nan_color=:black, c = cmap, climb=(amps[1],amps[end]))

    plot!(plt_rheobase, xlims=x_limits, ylims=y_limits)
    plot!(plt_spiking, xlims=x_limits, ylims=y_limits)

    ################### Lido Traj ###################
    # TFE.add_lido_shift_inhib_traj(plt_rheobase)
    # TFE.add_lido_shift_inhib_traj(plt_spiking)

    # ---------- save figures ---------- #

    savefig(plt_rheobase, "plots/$(folder_name)/$(file_prefix)_rheobase_plan.pdf")
    savefig(plt_spiking, "plots/$(folder_name)/$(file_prefix)_spiking_plan.pdf")
end

main()