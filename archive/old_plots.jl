

    # --- Plots --- #

    # p = plot(t, V, color= :black, label="")
    # #xlims!((400, 1700))
    # ylims!((-100, 0))
    # xlabel!("Time (ms)")
    # ylabel!("Voltage (mV)")

    # savefig("plots/plot_1.pdf")
    # print("plot 1\n")
    # display(p)

    # p = plot(V, m7.^3 .* h7 .* 100, color=:green, label="NaV1p7")
    # plot!(V, m8.^3 .* h8 .* 100, color=:blue, label="NaV1p8")
    # ylabel!("Availability (%)")
    # xlabel!("Voltage (mV)")
    # plot!(aspect_ratio = 1)

    # savefig("plots/plot_2.pdf")
    # print("plot 2\n")
    # display(p)

    # p = plot(layout = (2, 1))
    # x_range = (450, 600)

    # plot!(p[1], t, V)
    # xlims!(p[1], x_range)
    # ylims!(p[1], (-100, 50))
    # xlabel!(p[1], "Time (ms)")
    # ylabel!(p[1], "Voltage (mV)")

    # plot!(p[2], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium", legend = :topleft)
    # plot!(p[2], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")
    # xlims!(p[2], x_range)
    # #ylims!(p[2], (-250, 250))
    # xlabel!(p[2], "Time (ms)")
    # ylabel!(p[2], "Current (uA/cm2)")

    # savefig(p, "plots/plot_3.pdf")
    # print("plot 3\n")
    # # display(p)
    # # gui()
    # # readline()
    
    p = plot(layout = (2, 1))
    plot!(p[1], t, m3, label="m3")
    plot!(p[1], t, h3, label="h3")
    plot!(p[1], t, m7, label="m7")
    plot!(p[1], t, h7, label="h7")
    plot!(p[1], t, m8, label="m8")
    plot!(p[1], t, h8, label="h8")
    plot!(p[1], t, ndr, label="ndr")
    plot!(p[1], t, ldr, label="ldr")
    plot!(p[1], t, nm, label="nm")
    plot!(p[1], t, z_AHP, label="z_AHP")
    plot!(legendfontsize=6, legend=:topleft)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    plot!(p[2], t, V, label="amp = " + str(amp), color= :black)
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")
    savefig(p, "plots/plot_channels.pdf")
    print("plot channels\n")
    display(p)
    # gui()
    # readline()

    # p = plot(layout = (2, 1))
    # plot!(p[1], t, ndr, label="ndr")
    # plot!(p[2], t, ldr, label="ldr")
    # plot!(p[1], t, n_test, label="n_test")
    # plot!(p[2], t, l_test, label="l_test")
    # plot!(legendfontsize=4, legend=:topleft)
    # xlabel!(p[1], "Time (ms)")
    # ylabel!(p[1], "(-)")

    # """
    # plot!(p[2], t, V, label="V")
    # xlabel!(p[2], "Time (ms)")
    # ylabel!(p[2], "Voltage (mV)")
    # """
    # savefig(p, "plots/plot_l_n_test.pdf")
    # print("plot_l_n_test\n")
    # # gui()
    # # readline()