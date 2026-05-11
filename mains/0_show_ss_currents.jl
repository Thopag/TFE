
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

    alpha = 1
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    ylimits =  (-25, 0.5)

    plt = plot(xlabel=L"Voltage ($mV$)", ylabel= L"Steady State Current ($\mu A/cm^2$)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks)
    plot!(ylims=ylimits)

    reds, blues, greens, greys = sodium_palettes(L)

    # -------- put default values -------- #
    default_p = get_param(0.0)
    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = steady_state_currents(default_p, V)
    plot!(plt, V, .- IKdr, label=L"- K_{dr}", color=:orange, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IKm, label=L"- K_{M}", color=:purple, alpha=1, linewidth = 1.5)
    plot!(plt, V, .- IAHP, label=L"- K_{AHP}", color=:brown, alpha=1, linewidth = 1.5)

    # plot!(plt, V, INaV1p3, label=L"NaV1.3", color=:blue, alpha=1)
    # plot!(plt, V, INaV1p7, label=L"NaV1.7", color=:red, alpha=1)
    # plot!(plt, V, INaV1p8, label=L"NaV1.8", color=:green, alpha=1)

    # -------- Looping -------- #
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
    
        INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = steady_state_currents(p, V)
        
        plot!(plt, [], [], label=changing_label, color=greys[i], alpha=1)
        plot!(plt, V, INaV1p3, label="", color=blues[i], alpha=alpha)
        plot!(plt, V, INaV1p7, label="", color=reds[i], alpha=alpha)
        plot!(plt, V, INaV1p8, label="", color=greens[i], alpha=alpha)
    end

    savefig(plt, "plots/ss_current/$(file_prefix)ss_current.pdf")
end

main()