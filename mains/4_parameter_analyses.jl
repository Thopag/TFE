
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function init_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter)
    n_row = length(VEC_intra_parameter)
    n_col = length(VEC_inter_parameter)

    M_peak_count = Matrix{Int}(undef, n_row, n_col)
    M_freq = Matrix{Float32}(undef, n_row, n_col)
    M_pattern = Matrix{Int}(undef, n_row, n_col)
    M_first_peak_h = Matrix{Float32}(undef, n_row, n_col)
    M_first_peak_w = Matrix{Float32}(undef, n_row, n_col)

    inter_with_rheobase = Vector{String}()
    rheobases = Vector{Float32}()

    return M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
end

function iteration_parameter_analyses(i, params, u0, label, VEC_intra_parameter,
                                M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)

    VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w = parameter_analyse(params, u0;)

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

function end_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)
    
    return plot_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                    , intra_axe_label, inter_axe_label, inter_labels)
end

function main(;constant_amp=0.0)

    # -------- param vectors -------- #

    amps = 0.0:100:300.0                     #"amp (pA)"
    C_lido = [1.0, 10.0, 100.0, 1000.0]     #"Lidocaine (µM)"

    shifts = 0:0.5:15.0
    inhibs = 0:0.05:1.0

    constant_amp = constant_amp

    # ---------------- #

    file_prefix = "$(folder)_$(constant_amp)amp_40_60_shift_inhib_"

    # -------- Intra Parameter -------- #

    VEC_intra_parameter = inhibs
    intra_axe_label = "inhibitions (-)"
    
    # -------- Inter Parameter -------- #

    VEC_inter_parameter = shifts
    inter_axe_label = "shift (mV)"

    inter_labels = ["$k" for k in VEC_inter_parameter]
    L = length(VEC_inter_parameter)

    # -------- Init Matrices -------- #

    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases = init_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter)

    # -------- Parameter looping -------- #

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : $folder")
    println("lidocaine effect :")
    println(lidocaine_effect_setup())
    println("")
    println("INTRA simulations parameter is [$intra_axe_label]")
    println("   with values : $VEC_intra_parameter")
    println("")
    println("INTER simulations parameter is [$inter_axe_label]")
    println("   with values : $VEC_inter_parameter")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

    u0 = get_u0()
    println("################ Start Looping ################ ")
    for (i, (inter_parameter, label)) in enumerate(zip(VEC_inter_parameter, inter_labels))

        params = map(intra_parameter -> get_param(constant_amp;
        #"""###################### PARAMETER ######################"""#  
                    C_lidocaine=inter_parameter,
                    g_nav1p8 = 30.0 * (1.0 - intra_parameter),
                    )
        #"""#######################################################"""#
                    , VEC_intra_parameter)

        println("\n------ Start parameter analyse ------")
        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")
        iteration_parameter_analyses(i, params, u0, label, VEC_intra_parameter, 
                                            M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)
        println("------ End parameter analyses ------")
    end

    println("################ End Looping ################ ")

    println("---- Start Plots ----")

    p_peaks, p_freqs, p_height, p_width, p_rheo, p_plan, p_pattern = end_parameter_analyses(VEC_intra_parameter, VEC_inter_parameter, 
                                                                        M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                                    , intra_axe_label, inter_axe_label, inter_labels)

    # savefig(p_peaks, "plots/default/$(file_prefix)peaks-curve.pdf")
    # savefig(p_freqs, "plots/default/$(file_prefix)F-I-curve.pdf")
    # savefig(p_height, "plots/default/$(file_prefix)first_peak.pdf")
    # savefig(p_width, "plots/default/$(file_prefix)first_width.pdf")
    # savefig(p_rheo, "plots/default/$(file_prefix)rheobases.pdf")

    savefig(p_pattern, "plots/default/$(file_prefix)pattern.pdf")
    savefig(p_plan, "plots/default/$(file_prefix)heat_plan.pdf")

    println("---- End Plots ----")

end


# for i in 50:25:300.0
#     main(;constant_amp=i)
# end