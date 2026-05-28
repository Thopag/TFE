
############################ PARAMETER SET TYPE ############################
folder = "DIV7"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
elseif folder == "DIV7"
    get_param = DIV7_parameter
end

function main()

    V = -120.0:0.5:60.0

    # -------- Set up -------- #

    shifts = 0:1:15.0
    inhibs = 0.0:0.1:1.0

    changing_params = inhibs
    L = length(changing_params)
    file_prefix = "$(folder)_inhibition_1_8_"

    # -------- Plot Set up -------- #

    reds, blues, greens, greys = sodium_palettes(L)

    # -------- put default values -------- #

    plt = init_ss_currents(V, get_param)

    # -------- Looping -------- #
    for (i,inter_parameter) in enumerate(changing_params)
        #inhib = 0.0
        #shift = 0.0
        changing_label = "$(inter_parameter)"

        p  = get_param(0.0;
        #"""###################### PARAMETER ######################"""#   
                g_nav1p3 = 0.35 ,
                g_nav1p7 = 35.0 ,
                g_nav1p8 = 0.2 * (1.0-inter_parameter),
                )
        #"""#######################################################"""#
    
        iteration_ss_currents(plt, p, V, i, changing_label, reds, blues, greens, greys)
    end

    savefig(plt, "plots/default/$(file_prefix)ss_current.pdf")
end


#main()