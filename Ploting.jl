using Plots, LaTeXStrings

# 400 1700
# 545 565
xlimits = (400, 1700)

function plot_voltage(t, V, amp)

    p = plot(t, V, label=L"%$amp pA", color= :black, xlims=xlimits)
    xlabel!(p, "Time (ms)")
    ylabel!(p, "Voltage (mV)")

    savefig(p, "plots/plot_voltage.pdf")
    print("plot voltage\n")
    display(p)

end

function plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)

    p = plot(layout = (2, 1), xlims=xlimits)
    plot!(p[1], t, m3, label=L"m_{3}", linestyle = :solid, color=:blue)
    plot!(p[1], t, h3, label=L"h_{3}", linestyle = :dash, color=:blue)
    plot!(p[1], t, m7, label=L"m_{7}", linestyle = :solid, color=:red)
    plot!(p[1], t, h7, label=L"h_{7}", linestyle = :dash, color=:red)
    plot!(p[1], t, m8, label=L"m_{8}", linestyle = :solid, color=:green)
    plot!(p[1], t, h8, label=L"h_{8}", linestyle = :dash, color=:green)
    plot!(p[1], t, ndr, label=L"n_{dr}", linestyle = :solid, color=:orange)
    plot!(p[1], t, ldr, label=L"l_{dr}", linestyle = :dash, color=:orange)
    plot!(p[1], t, nm, label=L"n_{m}", linestyle = :solid, color=:purple)
    plot!(p[1], t, z_AHP, label=L"z_{AHP}", linestyle = :solid, color=:brown)
    plot!(p[1], legendfontsize=6, legend=:topright)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    plot!(p[2], t, V, label=L"%$amp pA", color= :black)
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")

    savefig(p, "plots/plot_variables.pdf")
    print("plot variables\n")
    #display(p)

end

function plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)

    p = plot(layout = (2, 1), xlims=xlimits)

    plot!(p[1], t, m7.^3 .* h7 .* 100, color=:red, label=L"NaV_{1.7}")
    plot!(p[1], t, m8.^3 .* h8 .* 100, color=:green, label=L"NaV_{1.8}")
    plot!(p[1], t, m3.^3 .* h3 .* 100, color=:blue, label=L"NaV_{1.3}")

    plot!(p[1], t, ndr.^3 .* ldr .* 100, color=:orange, label=L"K_{dr}")
    plot!(p[1], t, nm .* 100, color=:purple, label=L"K_{m}")
    plot!(p[1], t, z_AHP .* 100, color=:brown, label=L"AHP")
    ylabel!(p[1], "Availability (%)")
    xlabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, V, label=L"%$amp pA", color= :black)
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")

    savefig(p, "plots/plot_channels.pdf")
    print("plot channels\n")
    #display(p)

end