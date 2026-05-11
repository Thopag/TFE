
############################ PARAMETER SET TYPE ############################
folder = "DIV0"
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
    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.925, 0.95, 0.975, 1.0]

    changing_params = shifts
    L = length(changing_params)
    file_prefix = "$(folder)_1.8_40_60_shifts_"

    # -------- Plot Set up -------- #

    with_extra_plot = false

    xticks = [-120, -90, -60, -30, 0, 30, 60]
    colors = [get(colorschemes[:rainbow], i) for i in range(0.0, stop=1.0, length=L)]

    plt_f = plot(xlabel="Voltage (mV)", ylabel="g fast", xticks = xticks)
    plt_s = plot(xlabel="Voltage (mV)", ylabel="g slow", xticks = xticks)
    plt_us = plot(xlabel="Voltage (mV)", ylabel="g ultra slow", xticks = xticks)

    for (i,inter_parameter) in enumerate(changing_params)
        #inhib = 0.0
        #shift = 0.0
        changing_label = "$(inter_parameter)"

        p  = get_param(0.0;
        #"""###################### PARAMETER ######################"""#   
                with_inhibition = false,
                with_lido_shift = true,
                C_lidocaine=inter_parameter,
                )
        #"""#######################################################"""#
    
        g_f, g_s, g_us = DIC(V, p; with_plot=with_extra_plot)
        plot!(plt_f, V, g_f, label=changing_label, color=colors[i])
        plot!(plt_s, V, g_s, label=changing_label, color=colors[i])
        plot!(plt_us, V, g_us, label=changing_label, color=colors[i])
    end
    savefig(plt_f, "plots/DIC/$(file_prefix)all_g_f.pdf")
    savefig(plt_s, "plots/DIC/$(file_prefix)all_g_s.pdf")
    savefig(plt_us, "plots/DIC/$(file_prefix)all_g_us.pdf")
end

main()