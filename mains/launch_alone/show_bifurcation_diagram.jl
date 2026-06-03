############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    nociceptor_parameter = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    nociceptor_parameter = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    # ---- bifurcation set up ---- #

    u0 = get_u0()[1:end-1]
    #u0 = [-7.0407356746133765, 0.9870854072159283, 2.9653217237358692e-5, 0.9627214745221165, 7.519051987830313e-6, 0.8677369807299044, 0.009428204942099143, 0.992282714087809, 0.014777919108885743, 0.996285733438894, 0.04696791243885193]

    p_min = -300.0
    p_max = 600.0

    starting_param = 0.0
    lens_param = PropertyLens(:amp) ∘ PropertyLens(:stimulation)
    default_stim = stimulation_parameter(starting_param)

    # ---- inter bifurcation parameter ---- #

    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.95, 1.0]
    inter_params = inhibs
    L = length(inter_params)

    file_prefix = "$(folder)"

    # ---- Plot set up ---- #

    reds, blues, greens, greys = sodium_palettes(L; dark=0.95, light=0.5)

    intra_axe_label = "amp (pA)"
    plt, color_specialpoint = init_bifurcation(intra_axe_label, p_min, p_max, reds, greens, greys)

    for (i,inter_parameter) in enumerate(inter_params)
        inter_label = L"g_{NaV1.3} = %$(inter_parameter) "

        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")

        # ---- Make bifurcations ---- #

        p_lido = lidocaine_parameter(;)
        p_noci = nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0-inter_parameter))
        p_model = model_parameter(default_stim, p_noci; lidocaine=p_lido)

        br = iteration_bifurcation(plt, i, p_model, u0, lens_param, p_min, p_max,
                                                    inter_label, color_specialpoint, reds, greens, greys)

        # println(show(br))
        # println(br.branch.x[4000])
        # println(br.branch.param[4000])
    end

    # ----  End Plots ---- #

    #display(plt)
    savefig(plt, "plots/default/$(file_prefix)_bifurcation.png")
    savefig(plt, "plots/default/$(file_prefix)_bifurcation.pdf")

end

main()
