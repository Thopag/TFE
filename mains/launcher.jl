include("utils.jl")

function main()

    fp = nothing
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
    make_excitability_plan = false

    # -------- Initial Condition -------- #

    u0 = get_synapse_u0(set_u0_noci)

    # -------- Stimulation -------- #

    in_one_micro_A = 50.0 / 4.0

    #Ihold = -0.8 * in_one_micro_A # to change
    duration = 2000.0                               # ms
    stim_on = 500.0                                 # ms
    stim_length = 1200.0        # ms

    amp = 70.0 #* in_one_micro_A
    if !make_single_simulation
        # Put amp = 0.0 for bifurcation
        amp = 0.0
    end

    n_pulse = 5
    is_activated = nothing
    #is_activated = multiple_pulse(;T=(duration-stim_on)/n_pulse, n_pulse=n_pulse, start=500.0, length=150.0)
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold, is_act=is_activated)

    # -------- Inter Parameter -------- #

    inhibs = 0:0.5:0.0

    VEC_inter_parameter = inhibs
    VEC_label = ["$k" for k in VEC_inter_parameter]
    parameter_label = "inhibition (-)"

    file = "$(DIV)_default"

    # -------- Create the VEC_p_model -------- #

    pn = projection_neuron_parameter(;)
    s = synapse_parameter(;)

    VEC_p_noci = [nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0 - p)) for p in VEC_inter_parameter]
    VEC_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s) for n in VEC_p_noci]

    if make_single_simulation

        println("")
        println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
        println("Parameter set type : [$DIV]")
        println("Simulation of [$duration] ms")
        println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        println("")

        p_model = VEC_p_model[1]
        # -------- Single Simulation -------- #
        sol_n, sol_pn, sol_s = single_simulation(p_model, u0, duration; file_prefix = file)
        plot_single_simulation(sol_n, sol_pn, sol_s, p_model, duration; file_prefix = file)

    elseif make_excitability_plan

        println("")
        println("%%%%%%%%%%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%%%%")
        println("Parameter set type : [$DIV]")
        println("Simulation of [$duration] ms")
        println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        println("")

        @time plan_r = run_excitability_plan(u0, nociceptor_parameter, p_stim, duration)

        save(file; plan_r=plan_r)
        plot_plan(plan_r, file_prefix)
    else

        fp = file_parameters(u0, duration, VEC_p_model, VEC_label, parameter_label, DIV)
        analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)

        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
        plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    end

end

main()