export run_bifurcation_analyses

function run_bifurcation_analyses(DIV, nociceptor_parameter, set_u0_noci, get_u0_noci, Ihold;)

    u0 = zeros(Float64, 11)
    set_u0_noci(view(u0, 1:11))
    p_stim = stimulation_parameter(0.0; Ihold=Ihold)

    # -------- bif Parameter -------- #

    lens_param = PropertyLens(:amp) ∘ PropertyLens(:stimulation)
    #lens_param = @optic _.stimulation.amp
    amp_min = -300.0
    amp_max = 300.0

    # -------- Inter Parameter -------- #

    inhibs = 0:0.5:1.0

    VEC_inter_parameter = inhibs
    VEC_label = ["$k" for k in VEC_inter_parameter]

    # -------- Parameter looping -------- #

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : $DIV")
    println("")
    println("INTER values :  $VEC_inter_parameter")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")


    VEC_p_noci = map( (inter_parameter) -> nociceptor_parameter(; 
                                                g_NaV1p8 = 30.0 * (1.0-inter_parameter))

                                                , VEC_inter_parameter)

    VEC_p_model = map( (n) -> model_parameter(;stimulation=p_stim, nociceptor=n), VEC_p_noci)

    println("################ Start Looping ################ ")
    results = bifurcation_analyses(VEC_p_model, u0, lens_param, amp_min, amp_max, VEC_label)
    println("################ End Looping ################ ")

    return results
end
