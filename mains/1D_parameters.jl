
function make_1D_parameters(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    var = L"g_{NaV1.8}"

    # -------- Inter Parameter -------- #
    inhibs = 0.0:0.3:1.0
    shifts = 0.0:1.5:15.0
    shift_mg = -20.0:5.0:20.0
    amps = 10.0:0.5:14.0
    lidos = [0.0, 100.0, 1000.0]

    VEC_inter_parameter = 0.0:0.0
    VEC_label = ["$k" for k in VEC_inter_parameter]

    # VEC_inter_parameter_2 = [100.0, 1000.0]
    # VEC_label = ["" for (k,m) in zip(VEC_inter_parameter,VEC_inter_parameter_2)]

    parameter_label = ""

    # -------- Create the VEC_p_model -------- #
    C = 0.0
    # inhib = get_lidocaine_inhibition(C)[3]
    # shift = abs(lido_h8(C)) + abs(lido_m8(C))

    # inhib = get_lidocaine_inhibition(C)[2]
    # shift = abs(lido_h7(C))

    inhib = 0.0
    shift = 0.0

    n = nociceptor_parameter(;)
    pn = projection_neuron_parameter(;)
    s = synapse_parameter(;)
    lido = lidocaine_parameter(; shift_h8 = 0.0 * shift, shift_m8 = 0.0 * shift, shift_h7 = 0.0 * shift, with_shift = true)
    stim = p_stim

    VEC_p_stim = [change_stimulation_amp(amp, stim) for amp in VEC_inter_parameter]

    VEC_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * p, shift_h7 = 0.0 * p, shift_h8 = 0.0 , shift_m8 = 0.0,
                                                                shift_Mgblock = 0.0 * p, with_shift = true)
                                                                                     for p in VEC_inter_parameter]

    VEC_p_noci = [nociceptor_parameter(;g_NaV1p8 = 30.0 * (1-p)) for p in VEC_inter_parameter]
    VEC_p_proj = [projection_neuron_parameter(;) for p in VEC_inter_parameter]
    VEC_p_syn = [synapse_parameter(;g_NMDA = 1.0 * (1-p)) for p in VEC_inter_parameter]

    VEC_p_model = [model_parameter(;stimulation=stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for i in VEC_p_noci]
    #VEC_p_model = [model_parameter(;stimulation=stim, nociceptor=j, projection_neuron=pn, synapse=s, lidocaine=i) for (i,j) in zip(VEC_p_lido,VEC_p_noci) ]

    f_1D = file_1D(u0, duration, VEC_p_model, VEC_label, parameter_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return f_1D
end