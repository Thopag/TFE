
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

    with_extra_plot = false

    plt_f, plt_s, plt_us, rainbow = init_DIC(L)

    for (i,inter_parameter) in enumerate(changing_params)

        changing_label = L"%$inter_parameter"

        p_lido = lidocaine_parameter(;)
        p_noci = nociceptor_parameter(; g_NaV1p8 = 30.0 * (1.0-inter_parameter))
        p_model = model_parameter(default_stim, p_noci; lidocaine=p_lido)
    
        iteration_DIC(V, p_model, i, changing_label, plt_f, plt_s, plt_us, rainbow;with_extra_plot=with_extra_plot)
    end
    savefig(plt_f, "plots/default/$(file_prefix)_all_g_f.pdf")
    savefig(plt_s, "plots/default/$(file_prefix)_all_g_s.pdf")
    savefig(plt_us, "plots/default/$(file_prefix)_all_g_us.pdf")
end

main()
