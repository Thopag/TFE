
############################ PARAMETER SET TYPE ############################
folder = "DIV7"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
elseif folder == "DIV7"
    get_param = DIV7_parameter
end

function init_DIC(L)
    xticks = [-120, -90, -60, -30, 0, 30, 60]

    if L == 1
        rainbow = [:black]
    else
        rainbow = [get(colorschemes[:rainbow], i) for i in range(0.0, stop=1.0, length=L)]
    end

    plt_f = plot(xlabel="Voltage (mV)", ylabel="g fast", xticks = xticks)
    plt_s = plot(xlabel="Voltage (mV)", ylabel="g slow", xticks = xticks)
    plt_us = plot(xlabel="Voltage (mV)", ylabel="g ultra slow", xticks = xticks)
    return plt_f, plt_s, plt_us, rainbow
end

function iteration_DIC(V, p, i, inter_label, plt_f, plt_s, plt_us, colors;with_extra_plot=true)
    g_f, g_s, g_us = DIC(V, p; with_plot=with_extra_plot)
    plot!(plt_f, V, g_f, label=inter_label, color=colors[i])
    plot!(plt_s, V, g_s, label=inter_label, color=colors[i])
    plot!(plt_us, V, g_us, label=inter_label, color=colors[i])
end

function main()

    V = -120.0:0.5:60.0

    # -------- Set up -------- #

    shifts = 0:1:15.0
    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.925, 0.95, 0.975, 1.0]
    g_Km = [0.05, 0.5]

    changing_params = g_Km
    L = length(changing_params)
    file_prefix = "$(folder)"

    # -------- Plot Set up -------- #

    with_extra_plot = false

    plt_f, plt_s, plt_us, rainbow = init_DIC(L)

    for (i,inter_parameter) in enumerate(changing_params)
        #inhib = 0.0
        #shift = 0.0
        changing_label = L"g_{K_M} = %$inter_parameter"

        p  = get_param(0.0;
        #"""###################### PARAMETER ######################"""#   
                #C_lidocaine=inter_parameter,
                # g_nav1p3 = 0.0,
                # g_nav1p7 = 60.0,
                # g_nav1p8 = 0.2,
                g_Km = inter_parameter
                )
        #"""#######################################################"""#
    
        iteration_DIC(V, p, i, changing_label, plt_f, plt_s, plt_us, rainbow;with_extra_plot=with_extra_plot)
    end
    savefig(plt_f, "plots/default/$(file_prefix)_all_g_f.pdf")
    savefig(plt_s, "plots/default/$(file_prefix)_all_g_s.pdf")
    savefig(plt_us, "plots/default/$(file_prefix)_all_g_us.pdf")
end

#main()
