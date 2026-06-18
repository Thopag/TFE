
function plot_max_conductance_inhibition()

    lido_concentrations = 10 .^ range(log10(0.1), log10(10000), length=100)

    results = get_lidocaine_inhibition.(lido_concentrations)
    inhib_1_3 = [(1.0 .- r[1]) .* 100 for r in results]
    inhib_1_7 = [(1.0 .- r[2]) .* 100 for r in results]
    inhib_1_8 = [(1.0 .- r[3]) .* 100 for r in results]

    xticks = [10^-1, 10^0, 10^1, 10^2, 10^3, 10^4]
    plt = plot(xlabel="Lidocaine (µM)", ylabel= "inhibition (%)", xaxis=:log10, legend=:bottomright, xticks = xticks) 

    plot!(plt, lido_concentrations, inhib_1_3, label="NaV1.3", c=:blue)
    plot!(plt, lido_concentrations, inhib_1_7, label="NaV1.7", c=:red)
    plot!(plt, lido_concentrations, inhib_1_8, label="NaV1.8", c=:green)

    #display(plt)
    savefig(plt, "plots/report/lidocaine_max_conductance_inhibition.pdf")
end

plot_max_conductance_inhibition()

#-------------------------------------------------------------------------#

function lidocaine_shift()

    lido_concentrations = 10 .^ range(log10(0.1), log10(10000), length=100)

    xticks = [10^-1, 10^0, 10^1, 10^2, 10^3, 10^4]
    plt = plot(xlabel="Lidocaine (µM)", ylabel= "Shift (mV)", xaxis=:log10, legend=:bottomleft, xticks = xticks) 

    label = "Nav1.3 inactivation"
    color = :blue
    style = :dash
    shift_function = inact_1_3_shift

    plot!(plt, lido_concentrations, shift_function.(lido_concentrations), label=label, c=color, linestyle=style)

    fit_points = [0.1, 1000]
    scatter!(plt, fit_points, shift_function.(fit_points), label="", c=:black)

    display(plt)
    savefig(plt, "plots/report/lidocaine_shift_$label.pdf")
end

#lidocaine_shift()