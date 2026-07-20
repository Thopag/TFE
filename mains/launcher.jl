include("utils.jl")

function get_file_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    # -------- Inter Parameter -------- #
    inhibs = [0.0:0.1:0.9; 0.925:0.025:1.0]
    shift = 0.0:1.5:15.0
    amps = 10.0:0.5:14.0

    VEC_inter_parameter = inhibs
    VEC_label = ["$k" for k in VEC_inter_parameter]
    parameter_label = "Inhibition NaV1.3 (-)"

    # -------- Create the VEC_p_model -------- #

    n = nociceptor_parameter(;)
    pn = projection_neuron_parameter(;)
    s = synapse_parameter(;g_NMDA = 1.0)
    lido = lidocaine_parameter(;)
    stim = p_stim

    VEC_p_stim = [change_stimulation_amp(amp, stim) for amp in VEC_inter_parameter]

    VEC_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * p, shift_h7 = 0.0 * p, shift_h8 = 0.4 * p, shift_m8 = 0.6 * p
                                                                , with_shift = true, linear_shift_mode = true)
                                                                                     for p in VEC_inter_parameter]

    VEC_p_noci = [nociceptor_parameter(;g_NaV1p3 =  0.35 * (1 - p)) for p in VEC_inter_parameter]
    VEC_p_proj = [projection_neuron_parameter(;) for p in VEC_inter_parameter]
    VEC_p_syn = [synapse_parameter(;g_NMDA = 1.0 * (1-p)) for p in VEC_inter_parameter]

    VEC_p_model = [model_parameter(;stimulation=stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for i in VEC_p_noci]

    fp = file_parameters(u0, duration, VEC_p_model, VEC_label, parameter_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return fp
end

function get_plan_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    # -------- Row Parameter -------- #
    inhibs = 0:0.05:1.0

    VEC_row_param = 0:0
    row_label = "inhibition NaV1.8 (-)"
    # -------- Col Parameter -------- #
    inhibs = 0:0.05:1.0
    shift = 0.0:0.5:15.0

    VEC_col_param = 0:0
    col_label = ""
    # -------- Create matrix -------- #

    M_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * c, shift_h7 = 0.0 * c, shift_h8 = 0.0 * c, shift_m8 = 0.0 * c
                                                                , with_shift = true, linear_shift_mode = true) 
                                                                            for r in VEC_row_param, c in VEC_col_param]

    M_p_noci = [nociceptor_parameter(;g_NaV1p8 = 30.0 * (1-r)) for r in VEC_row_param, c in VEC_col_param]
    M_p_proj = [projection_neuron_parameter(;) for r in VEC_row_param, c in VEC_col_param]
    M_p_syn = [synapse_parameter(;g_NMDA = 1.0 * (1-c)) for r in VEC_row_param, c in VEC_col_param]

    M_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for (n,pn,s,lido) in zip(M_p_noci,M_p_proj,M_p_syn, M_p_lido)]

    pp = plan_parameters(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return pp
end

function main()

    DIV = "DIV0"

    # -------- File name -------- #

    #file = "inhibition/$(DIV)_NaV1.3_inhib"
    file = "$(DIV)_default"

    # -------- Launching options -------- #

    with_simulations = true
    make_plan = false
    make_analyses = false

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

    duration = 2000.0                   # ms
    stim_on = 300.0                    # ms
    stim_length = 1400.0               # ms

    amp = 55.0 #* in_one_micro_A

    n_pulse = 5
    is_activated = nothing
    #is_activated = multiple_pulse(;T=(duration-stim_on)/n_pulse, n_pulse=n_pulse, start=300.0, length=100.0)
    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold, is_act=is_activated)

    # --------------------------------------------------------------------- #

    fp = get_file_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)
    pp = get_plan_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    if with_simulations
        VEC_p_model = fp.VEC_p_model

        VEC_p_model = [VEC_p_model[1]]
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