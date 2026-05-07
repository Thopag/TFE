
############################ PARAMETER SET TYPE ############################
folder = "DIV7"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function parameter_creation(VEC_intra_parameter;
    kwargs...
    )

    amp = 404
    params = Vector{Model_Parameters}()
    for intra_parameter in VEC_intra_parameter
        param = get_param(intra_parameter;
        with_lido_shift=true,
        #with_inhibition=false,
        #C_lidocaine=0.0,
        #g_nav1p7=35.0 *(1-i),
        #g_nav1p3=0.35 *(1-i),
        #g_nav1p8=0.2 *(1-i),
        kwargs...)

        push!(params, param)
    end

    return params
end

function main()

    # -------- param vectors -------- #

    amps = 0.0:1.0:300.0
    C_lido = [0.0] #, 10.0, 100.0, 1000.0]

    # -------- Set parameter variation -------- #

    VEC_intra_parameter = amps
    VEC_inter_parameter = C_lido

    # -------- label parameters -------- #

    intra_axe_label = "amp (pA)"
    inter_axe_label = "Lidocaine (µM)"

    inter_labels = ["$k" for k in C_lido]

    # -------- Set up results structure -------- #
    
    n_row = length(VEC_intra_parameter)
    n_col = length(VEC_inter_parameter)

    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)
    M_first_peak_h = Matrix{Float32}(undef, n_row, n_col)
    M_first_peak_w = Matrix{Float32}(undef, n_row, n_col)

    inter_with_rheobase = Vector{String}()
    rheobases = Vector{Float32}()

    # -------- Parameter looping -------- #

    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("")
    println("INTRA simulations parameter is [$intra_axe_label]")
    println("   with values : $VEC_intra_parameter")
    println("")
    println("INTER simulations parameter is [$inter_axe_label]")
    println("   with values : $VEC_inter_parameter")

    u0 = get_u0()
    for (i, (inter_parameter, label)) in enumerate(zip(VEC_inter_parameter, inter_labels))

        params = parameter_creation(VEC_intra_parameter;
        #"""###################### PARAMETER ######################"""#   
                    C_lidocaine=inter_parameter)
        #"""#######################################################"""#  

        println("\n------ Start parameter analyse ------")
        println("Inter value : $inter_parameter -- $((i-1)/n_col*100) % is done")
        VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w = parameter_analyse(params, u0;)
        println("------ End parameter analyses ------")

        # Get the first parameter that has a spike
        # This is mainly used when the intra_parameter is "Amp"
        rheobase_idx = findfirst(x -> x >= 1, VEC_pattern)
        if !isnothing(rheobase_idx)
            push!(inter_with_rheobase, label)
            push!(rheobases, VEC_intra_parameter[rheobase_idx])
        end

        M_peak_count[:, i] = VEC_peak_count
        M_freq[:, i] = VEC_freq
        M_pattern[:, i] = VEC_pattern
        M_first_peak_h[:, i] = VEC_first_peak_h
        M_first_peak_w[:, i] = VEC_first_peak_w 
    end

    println("################ End Looping ################ ")

    println("---- Start Plots ----")

    p_peaks, p_freqs, p_height, p_width, p_rheo, p_plan, p_pattern = plot_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                                                                M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                                    , intra_axe_label, inter_axe_label, inter_labels)

    # display(p_peaks)
    # display(p_freqs)
    # display(p_window)
    # display(p_pattern)
    # display(p_rheo)
    # display(p_plan)

    savefig(p_peaks, "plots/parameter_analyses/peaks-curve.pdf")
    savefig(p_freqs, "plots/parameter_analyses/F-I-curve.pdf")
    savefig(p_height, "plots/parameter_analyses/first_peak.pdf")
    savefig(p_width, "plots/parameter_analyses/first_width.pdf")

    savefig(p_pattern, "plots/parameter_analyses/pattern.pdf")
    savefig(p_rheo, "plots/parameter_analyses/rheobases.pdf")
    savefig(p_plan, "plots/parameter_analyses/heat_plan.pdf")

    println("---- End Plots ----")

end

main()