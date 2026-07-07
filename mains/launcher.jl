include("utils.jl")

function get_file_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    # -------- Inter Parameter -------- #
    inhibs = [0.0:0.2:0.6; 0.8:0.1:0.9; 0.925:0.025:1.0]
    shift = 0.0:1.0:12.0

    VEC_inter_parameter = shift
    VEC_label = ["$k" for k in VEC_inter_parameter]
    parameter_label = "Shift m8 0.6 - h8 0.4 NaV1.8 (mV)"

    # -------- Create the VEC_p_model -------- #

    n = nociceptor_parameter(;)
    pn = projection_neuron_parameter(;)
    s = synapse_parameter(;)
    lido = lidocaine_parameter(;)

    VEC_p_lido = [lidocaine_parameter(;shift_h3 = 0.0, shift_h7 = 0.0, shift_h8 = 0.4 * p, shift_m8 = 0.6 * p
                                                                , with_shift = true, linear_shift_mode = true)
                                                                                     for p in VEC_inter_parameter]

    VEC_p_noci = [nociceptor_parameter(; g_NaV1p3 = 0.35 * (1.0 - p)) for p in VEC_inter_parameter]
    VEC_p_proj = [projection_neuron_parameter(;) for p in VEC_inter_parameter]
    VEC_p_syn = [synapse_parameter(;) for p in VEC_inter_parameter]

    VEC_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=i) for i in VEC_p_lido]

    fp = file_parameters(u0, duration, VEC_p_model, VEC_label, parameter_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return fp
end

function get_plan_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    # -------- Row Parameter -------- #
    inhibs = 0:0.1:1.0

    VEC_row_param = inhibs
    row_label = "inhibition NaV1.3 (-)"
    # -------- Col Parameter -------- #
    inhibs = 0:0.1:1.0
    shift = 0.0:2.5:25.0

    VEC_col_param = shift
    col_label = "shift h3 NaV1.3 (mV)"
    # -------- Create matrix -------- #

    M_p_lido = [lidocaine_parameter(;shift_h3 = 1.0 * c, shift_h7 = 0.0, shift_h8 = 0.0, shift_m8 = 0.0
                                                                , with_shift = true, linear_shift_mode = true) 
                                                                            for r in VEC_row_param, c in VEC_col_param]

    M_p_noci = [nociceptor_parameter(;g_NaV1p3 = 0.35 * (1-r)) for r in VEC_row_param, c in VEC_col_param]
    M_p_proj = [projection_neuron_parameter(;) for r in VEC_row_param, c in VEC_col_param]
    M_p_syn = [synapse_parameter(;) for r in VEC_row_param, c in VEC_col_param]

    M_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for (n,pn,s,lido) in zip(M_p_noci,M_p_proj,M_p_syn, M_p_lido)]

    pp = plan_parameters(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return pp
end

function main()

    DIV = "DIV0"

    # -------- File name -------- #

    file = "noci/$(DIV)_NaV1.8_m0.6_h0.4_shift"

    # -------- Launching options -------- #

    with_simulations = false
    make_plan = false
    make_analyses = true

    with_nociceptor = true
    with_projection_neuron = true

    # -------- PARAMETER SET TYPE -------- #

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

    fp = nothing
    analyse_r = nothing
    bifurcation_r = nothing
    DIC_r = nothing
    SS_current_r = nothing
    plan_exct = nothing
    plan_freq = nothing

    # -------- Initial Condition -------- #

    u0 = get_synapse_u0(set_u0_noci)

    # -------- Stimulation -------- #

    in_one_micro_A = 50.0 / 4.0

    #Ihold = -0.8 * in_one_micro_A # to change
    duration = 2000.0                               # ms
    stim_on = 300.0                                 # ms
    stim_length = 1300.0                            # ms

    amp = 70.0 #* in_one_micro_A

    n_pulse = 5
    is_activated = nothing
    #is_activated = multiple_pulse(;T=(duration-stim_on)/n_pulse, n_pulse=n_pulse, start=500.0, length=150.0)
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold, is_act=is_activated)

    # --------------------------------------------------------------------- #

    fp = get_file_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)
    pp = get_plan_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    if with_simulations
        VEC_p_model = fp.VEC_p_model

        #VEC_p_model = [VEC_p_model[1]]
        make_simulations(VEC_p_model, u0, duration, fp.VEC_label, DIV, with_nociceptor, with_projection_neuron; file_prefix = file)
    end
    if make_plan
        #plan_exct, plan_freq = launch_plan(pp, plan_exct, plan_freq)
        save(file; pp=pp, plan_exct=plan_exct, plan_freq=plan_freq)
        #plot_plan(pp, plan_exct, plan_freq, file)
    end
    if make_analyses
        #analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
        #plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    end
end

main()