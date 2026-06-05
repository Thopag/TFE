############################ PARAMETER SET TYPE ############################
parameter_set = "DIV0"
############################ PARAMETER SET TYPE ############################

if parameter_set == "DIV0"
    nociceptor_parameter = DIV0_parameter
    get_u0 = DIV0_u0
elseif parameter_set == "DIV7"
    nociceptor_parameter = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    V = -120.0:0.5:60.0
    u0 = get_u0()
    u0_bifurcation = u0[1:11]

    # -------- Vectors -------- #

    inhibs = 0:0.5:1.0

    # -------- Inter Parameter -------- #

    VEC_inter_parameter = inhibs
    inter_axe_label = "Inhibition NaV1.8 (-)"

    inter_labels = ["$k" for k in VEC_inter_parameter]
    L = length(VEC_inter_parameter)

    # -------- Amps -------- #

    amps = 0.0:50:300.0
    amp_axe_label = "amp (pA)"

    # For Bifurcation
    lens_amp = PropertyLens(:amp) ∘ PropertyLens(:stimulation)
    p_min = -amps[end]
    p_max = amps[end]
    default_amp = 0.0
    default_stim = stimulation_parameter(default_amp)

    VEC_stim = stimulation_parameter.(amps)

    # -------- General Labeling -------- #

    folder_name = "default"
    #folder_name = "$(parameter_set)_$(TFE.shift_inact_1p8)-inact-1.8_$(TFE.shift_act_1p8)-act-1.8" ######## FOLDER NAME ########
    #folder_name = "$(parameter_set)_$(TFE.shift_inact_1p7)-inact-1.7_$(TFE.shift_inact_1p3)-inact-1.3_$(TFE.shift_inact_1p8)-inact-1.8_$(TFE.shift_act_1p8)-act-1.8" ######## FOLDER NAME ########
    file_prefix = "$(folder_name)"

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Will be stored in $folder_name")
    println("Parameter set type : $parameter_set")
    println("")
    println("Amps values : $amps")
    println("")
    println("INTER simulations parameter is [$inter_axe_label]")
    println("   with values : $VEC_inter_parameter")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")

    # -------- initiations -------- #

    reds, blues, greens, greys = sodium_palettes(L)
    p_default_model = model_parameter(default_stim, nociceptor_parameter())

    plt_ss_current = init_ss_currents(V, p_default_model)
    plt_f, plt_s, plt_us, rainbow = init_DIC(L)
    plt_bif, color_specialpoint = init_bifurcation(amp_axe_label, p_min, p_max, reds, greens, greys)
    M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases = init_parameter_analyses(amps, VEC_inter_parameter)

    # -------- Parameter looping -------- #

    println("################ Start Looping ################ ")
    for (i, (inter_parameter, inter_label)) in enumerate(zip(VEC_inter_parameter, inter_labels))

        # Progression
        println()
        println("_____________________________________________________________________________")
        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")

        p_lido = lidocaine_parameter(;)
        p_noci = nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0-inter_parameter))

        VEC_p_model = map( (stimulation) -> model_parameter(stimulation, p_noci; lidocaine=p_lido), VEC_stim)
        p_model = model_parameter(default_stim, p_noci; lidocaine=p_lido)

        # -------- iterations -------- #

        iteration_ss_currents(plt_ss_current, p_model, V, i, inter_label, reds, blues, greens, greys)
        println("---Steady State Currents Done---")

        iteration_DIC(V, p_model, i, inter_label, plt_f, plt_s, plt_us, rainbow)
        println("------------DIC Done------------")

        println("-------Start Bifurcation--------")
        iteration_bifurcation(plt_bif, i, p_model, u0_bifurcation, lens_amp, p_min, p_max,
                                                    inter_label, color_specialpoint, reds, greens, greys)
        println("--------Bifurcation Done--------")

        println("----Start Parameter Analyses----")
        iteration_parameter_analyses(i, VEC_p_model, u0, inter_label, amps, 
                                            M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)
        println("----Parameter Analyses Done----")

    end

    println("################ End Looping ################ ")

    # -------- ending -------- #

    p_peaks, p_freqs, p_height, p_width, p_rheo, p_plan, p_pattern = end_parameter_analyses(amps, VEC_inter_parameter, 
                                                                        M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases
                                                                                                    , amp_axe_label, inter_axe_label, inter_labels)


    # ---------- save figures ---------- #

    println("-- Start Saving --")

    jldsave("plots/$(folder_name)/$(file_prefix)_all.jld2"; amps, VEC_inter_parameter, 
                                        M_peak_count, M_freq, M_pattern, M_first_peak_h, M_first_peak_w, inter_with_rheobase, rheobases)

    # -- Steady State Currents -- #
    savefig(plt_ss_current, "plots/$(folder_name)/$(file_prefix)_ss_current.pdf")

    # -- DIC -- #
    savefig(plt_f, "plots/$(folder_name)/$(file_prefix)_all_g_f.pdf")
    savefig(plt_s, "plots/$(folder_name)/$(file_prefix)_all_g_s.pdf")
    savefig(plt_us, "plots/$(folder_name)/$(file_prefix)_all_g_us.pdf")

    # -- Parameter analyses -- #
    savefig(p_peaks, "plots/$(folder_name)/$(file_prefix)_peaks-curve.pdf")
    savefig(p_freqs, "plots/$(folder_name)/$(file_prefix)_F-I-curve.pdf")
    savefig(p_height, "plots/$(folder_name)/$(file_prefix)_first_height.pdf")
    savefig(p_width, "plots/$(folder_name)/$(file_prefix)_first_width.pdf")

    savefig(p_pattern, "plots/$(folder_name)/$(file_prefix)_pattern.pdf")
    savefig(p_rheo, "plots/$(folder_name)/$(file_prefix)_rheobases.pdf")
    savefig(p_plan, "plots/$(folder_name)/$(file_prefix)_heat_plan.pdf")

    # -- Bifurcation -- #
    savefig(plt_bif, "plots/$(folder_name)/$(file_prefix)_bifurcation.png")
    # savefig(plt_bif, "plots/$(folder_name)/$(file_prefix)_bifurcation.pdf")

    println("-- End Saving --")
end

main()