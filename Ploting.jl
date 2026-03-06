__precompile__(true)
module Ploting

using Plots, LaTeXStrings

export empty_voltage_plot, plot_voltage, plot_variables, plot_channels, plot_currents, plot_all_currents, plot_test, plot_availability_voltage

function empty_voltage_plot(; xlimits=(400, 1700))
    p = plot(xlims=xlimits, xlabel="Time (ms)", ylabel= "Voltage (mV)")
    return p
end

function plot_voltage(t, V, amp, peaks_idx; given_p=nothing, with_peak=false, save=false)

    if isnothing(given_p)
        p = plot(t, V, label=L"%$amp pA", color= :black; xlimits=(400, 1700))
        xlabel!(p, "Time (ms)")
        ylabel!(p, "Voltage (mV)")
    else
        p = given_p
        plot!(p, t, V, label=L"%$amp pA", color= :black)
    end

    if with_peak && length(peaks_idx) > 0
        scatter!(p, t[peaks_idx], V[peaks_idx], label="", markersize=3, color=:red)
    end

    if save == true
        savefig(p, "plots/plot_voltage.pdf")
        print("save plot voltage\n")
        display(p)
    end

    return p
end

function plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp; xlimits=(400, 1700))

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

function plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp; xlimits=(400, 1700))

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

function plot_all_currents(t, V, I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, amp; xlimits=(400, 1700))

    p = plot(layout = (2, 1), xlims=xlimits)
    
    plot!(p[1], t, V, color= :black, label=L"%$amp pA")
    ylims!(p[1], (-100, 50))
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, I_NaV1p3, color=:blue, label=L"I_{NaV1.3}", legend = :bottomright)
    plot!(p[2], t, I_NaV1p7, color=:red, label=L"I_{NaV1.7}")
    plot!(p[2], t, I_NaV1p8, color=:green, label=L"I_{NaV1.8}")

    plot!(p[2], t, I_Kdr, color=:orange, label=L"I_{Kdr}")
    plot!(p[2], t, I_Km, color=:purple, label=L"I_{KM}")
    plot!(p[2], t, I_AHP, color=:brown, label=L"I_{AHP}")

    #ylims!(p[2], (-250, 250))
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Current (uA/cm2)")

    savefig(p, "plots/plot_all_currents.pdf")
    print("plot all currents\n")
end

function plot_currents(t, V, I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, amp; xlimits=(400, 1700))

    p = plot(layout = (2, 1), xlims=xlimits)
    
    plot!(p[1], t, V, color= :black, label=L"%$amp pA")
    ylims!(p[1], (-100, 50))
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium", legend = :bottomright)
    plot!(p[2], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")
    #ylims!(p[2], (-250, 250))
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Current (uA/cm2)")

    savefig(p, "plots/plot_currents.pdf")
    print("plot currents\n")
end

function plot_test(t, V, ndr, ldr, n_test, l_test, amp)

    p = plot(layout = (2, 1))

    plot!(p[1], t, ndr, label="ndr")
    plot!(p[1], t, ldr, label="ldr")
    plot!(p[1], t, n_test, label="n_test")
    plot!(p[1], t, l_test, label="l_test")
    plot!(legendfontsize=6, legend=:topleft)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    plot!(p[2], t, V, color= :black, label=L"%$amp pA")
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")

    savefig(p, "plots/plot_l_n_test.pdf")
    display(p)
    print("plot_l_n_test\n")
end

function plot_availability_voltage(t, V, m7, h7, m8, h8)

    p = plot(V, m7.^3 .* h7 .* 100, color=:green, label="NaV1p7")
    plot!(V, m8.^3 .* h8 .* 100, color=:blue, label="NaV1p8")
    ylabel!("Availability (%)")
    xlabel!("Voltage (mV)")
    plot!(aspect_ratio = 1)

    savefig("plots/plot_availability_voltage.pdf")
    print("plot availability voltage\n")
end

end