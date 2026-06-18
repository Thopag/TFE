############################ PARAMETER SET TYPE ############################
DIV = "DIV0"
############################ PARAMETER SET TYPE ############################

if DIV == "DIV0"
    nociceptor_parameter = DIV0_parameter
    set_u0_noci = DIV0_u0
    get_u0_noci = get_DIV0_u0
    Ihold = -3.0
elseif DIV == "DIV7"
    nociceptor_parameter = DIV7_parameter
    set_u0_noci = DIV7_u0
    get_u0_noci = get_DIV7_u0
    Ihold = 0.0
end

function main(;)

    u0 = get_u0_noci()

    duration = 1700.0
    stim_on = 500.0                                 # ms
    stim_length = duration - stim_on - 200.0        # ms

    # -------- amp vectors -------- #

    VEC_amp = 0.0:150:300.0
    p_stim = stimulation_parameter(0.0; on=stim_on, length=stim_length, Ihold=Ihold)

    # -------- Inter Parameter -------- #

    inhibs = 0:0.5:1.0

    VEC_inter_parameter = inhibs
    VEC_label = ["$k" for k in VEC_inter_parameter]
    parameter_label = "inhibition (-)"

    # -------- Parameter looping -------- #

    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : $DIV")
    println("")
    println("Amps values : $VEC_amp")
    println("")
    println("INTER values :  $VEC_inter_parameter")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")


    VEC_p_noci = map( (inter_parameter) -> nociceptor_parameter(; 
                                                g_NaV1p8 = 30.0 * (1.0-inter_parameter))

                                                , VEC_inter_parameter)

    VEC_p_model = map( (n) -> model_parameter(;stimulation=p_stim, nociceptor=n), VEC_p_noci)

    println("################ Start Looping ################ ")
    @time results = parameter_analyses(VEC_amp, VEC_p_model, duration, u0, VEC_label, parameter_label)
    println("################ End Looping ################ ")

    # Mute the warning about function saving
    with_logger(ConsoleLogger(stderr, Logging.Error)) do
        jldsave("plots/JLD2_save/$(DIV)_test.jld2"; results)
    end
    return
end

main()