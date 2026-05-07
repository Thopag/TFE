
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

    shifts = [0.0, 7.0, 14.0]
    inhibs = [0.0, 0.0, 0.0]

    changing_params = zip(shifts, inhibs)

    # -------- Plot Set up -------- #

    with_extra_plot = false

    xticks = [-120, -90, -60, -30, 0, 30, 60]

    plt_f = plot(xlabel="Voltage (mV)", ylabel="g fast", xticks = xticks)
    plt_s = plot(xlabel="Voltage (mV)", ylabel="g slow", xticks = xticks)
    plt_us = plot(xlabel="Voltage (mV)", ylabel="g ultra slow", xticks = xticks)

    for (shift, inhib) in changing_params
        #inhib = 0.0
        #shift = 0.0
        changing_label = "s = $shift | i = $inhib"

        p  = get_param(0.0;
            with_inhibition = false,
            with_lido_shift = true,
            C_lidocaine = shift,
            #Put inhibition
            )
    
        g_f, g_s, g_us = DIC(V, p; with_plot=with_extra_plot)
        plot!(plt_f, V, g_f, label=changing_label)
        plot!(plt_s, V, g_s, label=changing_label)
        plot!(plt_us, V, g_us, label=changing_label)
    end
    savefig(plt_f, "plots/DIC/all_g_f.pdf")
    savefig(plt_s, "plots/DIC/all_g_s.pdf")
    savefig(plt_us, "plots/DIC/all_g_us.pdf")
end

main()