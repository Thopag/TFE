using Plots, LaTeXStrings
#pyplot()

function figure()

    fig1 = plot(V, S.(V), label= L"S(V)")
    plot!(V, [f_µP0.(V, 1.8) f_µP0.(V, 2.5) f_µP0.(V, 3.2)], label=[ L"µ P_{0} = 1.8" L"µ P_{0} = 2.5" L"µ P_{0} = 3.2"])

    xlims!(0, 6)
    ylims!(0, 1.5)

    xlabel!(L"V")
    ylabel!(" ")
    title!("Figure 1")

    display(fig1)
    savefig(fig1, "fig1.pdf")
end


function plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)

    p = plot(layout = (2, 1), xlims=(400, 1700))
    plot!(p[1], t, m3, label=L"m_{3}")
    plot!(p[1], t, h3, label=L"h_{3}")
    plot!(p[1], t, m7, label=L"m_{7}")
    plot!(p[1], t, h7, label=L"h_{7}")
    plot!(p[1], t, m8, label=L"m_{8}")
    plot!(p[1], t, h8, label=L"h_{8}")
    plot!(p[1], t, ndr, label=L"n_{dr}")
    plot!(p[1], t, ldr, label=L"l_{dr}")
    plot!(p[1], t, nm, label=L"n_{m}")
    plot!(p[1], t, z_AHP, label=L"z_{AHP}")
    plot!(p[1], legendfontsize=6, legend=:topleft)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    plot!(p[2], t, V, label=L"%$amp pA", color= :black)
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")

    savefig(p, "plots/plot_channels.pdf")
    print("plot channels\n")
    display(p)
    # gui()
    # readline()

end