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

    u0 = get_u0()
    amps = 0.0:0.5:300.0

    # -------- Vectors -------- #

    shifts = 0:0.5:15.0
    inhibs = 0:0.05:1.0

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

    M_rheobase = Matrix{Union{Nothing, Float32}}(undef, n_row, n_col)

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
        
            M_rheobase[i, j] = find_rheobase(param_function, amps, u0)
        end
    end

    println("################ End Looping ################ ")

    # ---------- make heatmap ---------- #

    plt = plot(xlabel=second_param_label, ylabel=first_param_label)

    heatmap!(plt, VEC_second_param, VEC_first_param, permutedims(M_rheobase), c = cgrad(:RdYlGn_4))

    diff_x = VEC_second_param[2]-VEC_second_param[1]
    diff_y = VEC_first_param[2]-VEC_first_param[1]

    x_limits = (-diff_x/8, VEC_second_param[end] + diff_x/8)
    y_limits = (-diff_y/8, VEC_first_param[end] + diff_y/8)

    plot!(plt, xlims=x_limits, ylims=y_limits)

    ################### Lido Traj ###################
    TFE.add_lido_shift_inhib_traj(plt)

    # ---------- save figures ---------- #

    savefig(plt, "plots/$(folder_name)/$(file_prefix)_rheobase_plan.pdf")
end

main()