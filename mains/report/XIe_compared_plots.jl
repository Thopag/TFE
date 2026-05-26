

function main()

    amp = 0.0

    folder = "DIV7"
    fig = "clamp"

    xrheo = 3.0

    if folder == "DIV0"
        get_param = DIV0_parameter
        get_u0 = DIV0_u0

        amp = 17.0
        g_nav1p3 = 0.0 
        g_nav1p8 = 30.0
        g_nav1p7 = 3.0
        if fig == "pharma"
            amp = 22.0
            g_nav1p8 = 4.0
        elseif fig == "clamp"
            amp = 5.0
            g_nav1p8 = 4.0
            g_nav1p7 = 40.0
        else
            fig = "default"
        end
    elseif folder == "DIV7"
        get_param = DIV7_parameter
        get_u0 = DIV7_u0

        amp = 12.0
        g_nav1p3 = 0.35 
        g_nav1p8 = 0.2
        g_nav1p7 = 35.0
        if fig == "pharma"
            amp = 16.0
            g_nav1p7 = 10.5
        elseif fig == "clamp"
            amp = 15.0
            g_nav1p7 = 10.5
            g_nav1p8 = 40.0
        else
            fig = "default"
        end
    end

    u0 = get_u0()

    amp = xrheo*amp

    param = get_param(amp;
        with_noise = true,
        g_nav1p3 = g_nav1p3,
        g_nav1p8 = g_nav1p8,
        g_nav1p7 = g_nav1p7,
        )

    file_prefix = "$(folder)_$(fig)_x$(xrheo)_rheo"

    xlimits = (param.stim_on - 50, 1500)
    ylimits = (-90,50)

    plt = plot(xlabel="Time (ms)", ylabel="Voltage (mV)", ylims=ylimits, xlims=xlimits, size = (750, 230),
                                                                        left_margin = 5mm,
                                                                        bottom_margin = 5mm, 
                                                                        margin = 5mm)

    print("------------------------------\n")
    print("make : $file_prefix\n")

    for i in 0:10
        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, 1700), param)

        # --- Plots --- #
            
        plot!(plt, t, V, color= :black, label="", alpha=0.4)
    end
    annotate!(plt,
        xlimits[2] - 0.05*(xlimits[2]-xlimits[1]),
        ylimits[2] - 0.0*(ylimits[2]-ylimits[1]),
        text( L"%$amp \: pA", 11, :black))


    savefig(plt, "plots/report/$(file_prefix).png")


    print("------------------------------\n")
end

main()