

function main()

    #### PARAMETER SET TYPE ####
    DIV = "DIV0"
    ############################

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
    
    # single_simulation(DIV, nociceptor_parameter, set_u0_noci, get_u0_noci, Ihold;)

    results = run_parameter_analyses(DIV, nociceptor_parameter, set_u0_noci, get_u0_noci, Ihold;)
    # Mute the warning about function saving
    with_logger(ConsoleLogger(stderr, Logging.Error)) do
        jldsave("JLD2_save/$(DIV)_test.jld2"; results)
    end

end

main()