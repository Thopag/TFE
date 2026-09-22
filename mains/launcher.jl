include("utils.jl")

function get_file_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    var = L"g_{NaV1.8}"

    # -------- Inter Parameter -------- #
    inhibs = 0.0:0.2:1.0
    shift = 0.0:2.5:25.0
    shift_mg = -20.0:5.0:20.0
    amps = 10.0:0.5:14.0

    VEC_inter_parameter = 0.0:0.0
    VEC_label = ["" for k in VEC_inter_parameter]

    # VEC_inter_parameter_2 = [0.0, 0.64]
    # VEC_label = ["" for (k,m) in zip(VEC_inter_parameter,VEC_inter_parameter_2)]

    parameter_label = "inhibition gNaV1.7"

    # -------- Create the VEC_p_model -------- #

    n = nociceptor_parameter(;)
    pn = projection_neuron_parameter(;)
    s = synapse_parameter(;)
    lido = lidocaine_parameter(;shift_m8 = 9.0, with_shift = true)
    stim = p_stim

    VEC_p_stim = [change_stimulation_amp(amp, stim) for amp in VEC_inter_parameter]

    VEC_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * p, shift_h7 = 0.0 * p, shift_h8 = 0.0 * p, shift_m8 = 0.0 * p,
                                                                shift_Mgblock = 0.0 * p, with_shift = true)
                                                                                     for p in VEC_inter_parameter]

    VEC_p_noci = [nociceptor_parameter(;g_NaV1p7 = 70.0 * (1-p)) for p in VEC_inter_parameter]
    VEC_p_proj = [projection_neuron_parameter(;) for p in VEC_inter_parameter]
    VEC_p_syn = [synapse_parameter(;g_NMDA = 1.0 * (1-p)) for p in VEC_inter_parameter]

    VEC_p_model = [model_parameter(;stimulation=stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for i in VEC_p_noci]
    #VEC_p_model = [model_parameter(;stimulation=stim, nociceptor=j, projection_neuron=pn, synapse=s, lidocaine=i) for (i,j) in zip(VEC_p_lido,VEC_p_noci) ]

    fp = file_parameters(u0, duration, VEC_p_model, VEC_label, parameter_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return fp
end

function get_plan_parameter(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    var = L"h_{8, \infty}"

    # -------- Row Parameter -------- #
    inhibs = 0.0:0.05:1.0

    VEC_row_param = inhibs
    row_label = "Inhibition NMDA (-)"
    # -------- Col Parameter -------- #
    inhibs = 0:0.05:1.0
    shift = 0.0:1.5:15.0
    Mg_shift = -20.0:5.0:20.0

    VEC_col_param = Mg_shift
    col_label = "Shift Mgblock (mV)"
    # -------- Create matrix -------- #

    M_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * c, shift_h7 = 0.0 * c, shift_h8 = 0.0 * c, shift_m8 = 0.0 * c,
                                                                shift_Mgblock = 1.0 * c , with_shift = true) 
                                                                            for r in VEC_row_param, c in VEC_col_param]

    M_p_noci = [nociceptor_parameter(;) for r in VEC_row_param, c in VEC_col_param]
    M_p_proj = [projection_neuron_parameter(;) for r in VEC_row_param, c in VEC_col_param]
    M_p_syn = [synapse_parameter(;g_NMDA = 1.0 * (1-r)) for r in VEC_row_param, c in VEC_col_param]

    M_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for (n,pn,s,lido) in zip(M_p_noci,M_p_proj,M_p_syn, M_p_lido)]

    pp = plan_parameters(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return pp
end

function main()

    DIV = "DIV0"

    # -------- File name -------- #

    file = "$(DIV)_default"
    #file = "inhibition/$(DIV)_2x_g7_inhib"

    # -------- Launching options -------- #

    with_simulations = true
    make_plan = false
    make_analyses = false
    rheobase = false

    with_nociceptor = true
    with_projection_neuron = false

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

    duration = 450.0                   # ms
    stim_on = 300.0                    # ms
    stim_length = 1400.0               # ms

    amp = 250.0

    n_pulse = 7
    is_activated = nothing
    #is_activated = multiple_pulse(;T=(duration-stim_on)/n_pulse, n_pulse=n_pulse, start=300.0, length=50.0)
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
        analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
        plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    end
    if rheobase
        run_rheobase_bar(fp.VEC_p_model, u0, duration, fp.VEC_label, fp.parameter_label; file = file)
    end
end

main()