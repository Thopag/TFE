

function main()

    analyse_r = nothing
    bifurcation_r = nothing
    DIC_r = nothing
    SS_current_r = nothing
    plan_r = nothing

    # -------- PARAMETER SET TYPE -------- #

    DIV = "DIV0"
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

    make_single_simulation = false
    make_excitability_plan = true

    # -------- Initial Condition -------- #

    # The following analyses are on the nociceptor only but can carry the complete u0
    u0 = get_synapse_u0(set_u0_noci)

    # -------- Stimulation -------- #

    duration = 1700.0                               # ms
    stim_on = 500.0                                 # ms
    stim_length = duration - stim_on - 200.0        # ms

    if make_single_simulation
        amp = 51.0
    else
        # Put amp = 0.0 for bifurcation
        amp = 0.0
    end
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold)

    # -------- Inter Parameter -------- #

    inhibs = 0:0.1:1.0

    VEC_inter_parameter = inhibs
    VEC_label = ["$k" for k in VEC_inter_parameter]
    parameter_label = "inhibition (-)"

    # -------- INFO -------- #

    println("")
    println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$DIV]")
    println("Simulation of [$duration] ms")

    # -------- Create the VEC_p_model -------- #

    VEC_p_noci = [nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0 - p)) for p in VEC_inter_parameter]
    VEC_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n) for n in VEC_p_noci]

    if make_single_simulation

        println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        println("")
        p_model = VEC_p_model[1]
        # -------- Single Simulation -------- #
        sol_n, sol_pn, sol_s = single_simulation(p_model, u0, duration; file_prefix = "default")
        plot_single_simulation(sol_n, sol_pn, sol_s, p_model, duration; file_prefix = "default")

    elseif make_excitability_plan

        println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        println("")
        @time plan_r = run_excitability_plan(u0, nociceptor_parameter, p_stim, duration)

        println("")
        println("----------- Start Saving -----------")
        # Mute the warning about function saving
        with_logger(ConsoleLogger(stderr, Logging.Error)) do
            @time jldsave("JLD2_save/$(DIV)_plan_test.jld2"; analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r)
        end
        println("----------- Finish Saving -----------")

        println("")
        println("----------- Start Ploting -----------")
        plot_excitability_plan(plan_r; file_prefix = "default")
        println("----------- End Ploting -----------")
    else
        println("")
        println("Inter parameter is [$(parameter_label)]")
        println("With vector : [$(VEC_inter_parameter)]")
        println("And labels : [$(VEC_label)]")
        println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        println("")
        # -------- Analyses -------- #
    
        analyse_r     = run_parameter_analyses(u0, VEC_p_model, VEC_label, parameter_label, duration)
        bifurcation_r = run_bifurcation_analyses(u0, VEC_p_model, VEC_label)
        DIC_r         = run_DIC_analyses(VEC_p_model, VEC_label)
        SS_current_r  = run_SS_current_analyses(VEC_p_model, VEC_label)                                                                                                                                                             

        # -------- Saving -------- #

        println("")
        println("----------- Start Saving -----------")
        # Mute the warning about function saving
        with_logger(ConsoleLogger(stderr, Logging.Error)) do
            @time jldsave("JLD2_save/$(DIV)_test.jld2"; analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r)
        end
        println("----------- Finish Saving -----------")

        println("")
        println("----------- Start Ploting -----------")
        plot_parameter_analyses(analyse_r; file_prefix = "default")
        println("----------- End Ploting -----------")
    end

end

main()