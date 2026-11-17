
function make_2D_parameters(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    # -------- Row Parameter (y axis) -------- #
    shift = 0.0:1:15.0

    VEC_row_param = shift 
    row_label = "0.4 h8 - 0.6 m8 (mV)"
    # -------- Col Parameter (x axis) -------- #
    inhibs = 0.0:0.05:1.0

    VEC_col_param = inhibs
    col_label = "Inhibition (-)"
    # -------- Create matrix -------- #

    M_p_lido = [lidocaine_parameter(;shift_h3 = 0.0 * r, shift_h7 = 0.0 * r, shift_h8 = 0.4 * r, shift_m8 = 0.6 * r, with_shift = true) 
                                                                            for r in VEC_row_param, c in VEC_col_param]

    M_p_noci = [nociceptor_parameter(;g_NaV1p8 = 30.0 * (1.0-c) ) for r in VEC_row_param, c in VEC_col_param]
    M_p_proj = [projection_neuron_parameter(;) for r in VEC_row_param, c in VEC_col_param]
    M_p_syn = [synapse_parameter(;) for r in VEC_row_param, c in VEC_col_param]

    M_p_model = [model_parameter(;stimulation=p_stim, nociceptor=n, projection_neuron=pn, synapse=s, lidocaine=lido) for (n,pn,s,lido) in zip(M_p_noci,M_p_proj,M_p_syn, M_p_lido)]

    f_2D = file_2D(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label
                                                            , DIV, with_nociceptor, with_projection_neuron)

    return f_2D
end