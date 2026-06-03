
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    nociceptor_parameter = DIV0_parameter
elseif folder == "DIV7"
    nociceptor_parameter = DIV7_parameter
end

function main()

    V = -120.0:0.5:60.0
    default_stim = stimulation_parameter(0.0)

    # -------- Set up -------- #

    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.925, 0.95, 0.975, 1.0]

    changing_params = inhibs
    L = length(changing_params)
    file_prefix = "$(folder)"

    # -------- Plot Set up -------- #

    reds, blues, greens, greys = sodium_palettes(L)

    # -------- put default values -------- #

    p_default_model = model_parameter(default_stim, nociceptor_parameter())
    plt = init_ss_currents(V, p_default_model)

    # -------- Looping -------- #
    for (i,inter_parameter) in enumerate(changing_params)
        changing_label = "$(inter_parameter)"

        p_lido = lidocaine_parameter(;)
        p_noci = nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0-inter_parameter))
        p_model = model_parameter(default_stim, p_noci; lidocaine=p_lido)
    
        iteration_ss_currents(plt, p_model, V, i, changing_label, reds, blues, greens, greys)
    end

    savefig(plt, "plots/default/$(file_prefix)_ss_current.pdf")
end


main()