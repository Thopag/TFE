
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    nociceptor_parameter = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    nociceptor_parameter = DIV7_parameter
    get_u0 = DIV7_u0
end

function main(;)

    # -------- amp vectors -------- #

    amps = 0.0:50:300.0
    amp_axe_label = "amp (pA)"
    VEC_stim = stimulation_parameter.(amps)

    # -------- Inter Parameter -------- #

    inhibs = 0:0.5:1.0

    VEC_inter_parameter = inhibs
    inter_axe_label = "inhibitions (-)"
    inter_labels = ["$k" for k in VEC_inter_parameter]

    file_prefix = "$(folder)"

    # -------- Init Matrices -------- #

    L = length(VEC_inter_parameter)
    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases = init_parameter_analyses(amps, VEC_inter_parameter)

    # -------- Parameter looping -------- #

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : $folder")
    println("")
    println("Amps values : $amps")
    println("")
    println("INTER simulations parameter is [$inter_axe_label]")
    println("   with values : $VEC_inter_parameter")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

    u0 = get_u0()
    println("################ Start Looping ################ ")
    for (i, (inter_parameter, label)) in enumerate(zip(VEC_inter_parameter, inter_labels))

        p_lido = lidocaine_parameter(;)
        p_noci = nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0-inter_parameter))
        VEC_p_model = map( (stimulation) -> model_parameter(stimulation, p_noci; lidocaine=p_lido), VEC_stim)

        println("\n------ Start parameter analyse ------")
        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")
        iteration_parameter_analyses(i, VEC_p_model, u0, label, amps, 
                                            M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)
        println("------ End parameter analyses ------")
    end

    println("################ End Looping ################ ")

    println("---- Start Plots ----")

    p_peaks, p_freqs, p_height, p_width, p_rheo, p_plan, p_pattern = end_parameter_analyses(amps, VEC_inter_parameter, 
                                                                        M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                                    , amp_axe_label, inter_axe_label, inter_labels)

    # savefig(p_peaks, "plots/default/$(file_prefix)peaks-curve.pdf")
    # savefig(p_freqs, "plots/default/$(file_prefix)F-I-curve.pdf")
    # savefig(p_height, "plots/default/$(file_prefix)first_peak.pdf")
    # savefig(p_width, "plots/default/$(file_prefix)first_width.pdf")
    # savefig(p_rheo, "plots/default/$(file_prefix)rheobases.pdf")

    savefig(p_pattern, "plots/default/$(file_prefix)pattern.pdf")
    savefig(p_plan, "plots/default/$(file_prefix)heat_plan.pdf")

    jldsave("plots/$(folder_name)/$(file_prefix)_parameter_analyses.jld2"; amps, VEC_inter_parameter, 
                                        M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)

    println("---- End Plots ----")

end

main()