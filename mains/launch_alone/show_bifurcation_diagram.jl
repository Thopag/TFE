############################ PARAMETER SET TYPE ############################
folder = "DIV7"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    # ---- bifurcation set up ---- #

    u0 = get_u0()[1:end-1]
    #u0 = [-7.0407356746133765, 0.9870854072159283, 2.9653217237358692e-5, 0.9627214745221165, 7.519051987830313e-6, 0.8677369807299044, 0.009428204942099143, 0.992282714087809, 0.014777919108885743, 0.996285733438894, 0.04696791243885193]

    p_min = -300.0
    p_max = 600.0

    starting_param = 0.0
    lens_param = PropertyLens(:amp)

    # ---- inter bifurcation parameter ---- #

    C_lido = [0.0, 10.0, 100.0, 1000.0]
    shifts = 0:1.5:15.0
    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.95, 1.0]
    g_1p7 = [35.0, 50.0, 65.0, 80.0, 95.0]
    g_1p3 = [0.0] #, 0.035, 0.1, 0.35, 1.0]
    g_1p8 = 5.0:15.0:50.0
    g_Km = [0.05, 0.5]
    inter_params = g_1p3
    L = length(inter_params)

    file_prefix = "$(folder)"
    #file_prefix = "$(folder)_$(TFE.shift_inact_1p8)-inact-1.8_$(TFE.shift_act_1p8)-act-1.8"

    # ---- Plot set up ---- #

    reds, blues, greens, greys = sodium_palettes(L; dark=0.95, light=0.5)

    intra_axe_label = "amp (pA)"
    plt, color_specialpoint = init_bifurcation(intra_axe_label, p_min, p_max, reds, greens, greys)

    println(lidocaine_effect_setup())
    for (i,inter_parameter) in enumerate(inter_params)
        inter_label = L"g_{NaV1.3} = %$(inter_parameter) "

        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")

        # ---- Make bifurcations ---- #
        param_init = get_param(starting_param;
        #"""###################### PARAMETER ######################"""#   
                    # C_lidocaine=inter_parameter,
                    g_nav1p3 = inter_parameter,
                    g_nav1p7 = 60.0,
                    # g_nav1p8 = inter_parameter,
                    # g_Km = 0.5,
                    )
        #"""#######################################################"""#

        br = iteration_bifurcation(plt, i, param_init, u0, lens_param, p_min, p_max,
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
