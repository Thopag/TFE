

# ------------------- CONDUCTANCE INHIBITION ------------------- #

hill(D, f_max, IC50, h, y0) = y0 + (f_max * D^h) / (IC50^h + D^h)

# Differential Block of Sensory Neuronal Voltage-Gated Sodium Channels
lidocain_1_3_resting_inib(D) = hill(D, 0.997, 1462, 1.35, 0)
lidocain_1_7_resting_inib(D) = hill(D, 0.994, 718, 1.02, 0)

lidocain_1_3_inact_inib(D) = hill(D, 0.949, 284, 0.48, 0)
lidocain_1_7_inact_inib(D) = hill(D, 0.992, 44, 0.43, 0)

# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine
lidocain_1_7_channel(D) = hill(D, 1.0079, 477.1, 1.31, 1.52 / 100)
lidocain_1_8_channel(D) = hill(D, 0.9698, 118.31, 1.06, 4.78 / 100)

# Fundamental Properties of local Anesthetics: Half-Maximal Blocking Concentrations for Tonic Block of Na+ and K+ Channels in Peripheral Nerve
lidocain_Na(D) = hill(D, 1, 204, 0.99, 0)
lidocain_K(D) = hill(D, 0.8, 1118, 1.22, 0)

function plot_hill()

    D = 10 .^ range(log10(0.1), log10(100000), length=100)

    plt = plot(xlabel="Lidocaine (µM)", ylabel= "inhibition (%)") 
    plot!(plt, xaxis=:log10, xlims=(0.1, 10000), legend=:topleft)

    # plot!(plt, D, lidocain_1_7_resting_inib.(D) .* 100, label="NaV 1.7 resting", linestyle = :dot, color=:red)
    # plot!(plt, D, lidocain_1_7_inact_inib.(D) .* 100, label="NaV 1.7 inact", linestyle = :dash, color=:red)
    plot!(plt, D, lidocain_1_7_channel.(D) .* 100, label="NaV 1.7 channel", linestyle = :solid, color=:red)

    # plot!(plt, D, lidocain_1_3_resting_inib.(D) .* 100, label="NaV 1.3 resting", linestyle = :dot, color=:blue)
    # plot!(plt, D, lidocain_1_3_inact_inib.(D) .* 100, label="NaV 1.3 inact", linestyle = :dash, color=:blue)

    plot!(plt, D, lidocain_1_8_channel.(D) .* 100, label="NaV 1.8 channel", linestyle = :solid, color=:green)

    # plot!(plt, D, lidocain_Na.(D) .* 100, label="Na", linestyle = :solid, color=:purple)
    # plot!(plt, D, lidocain_K.(D) .* 100, label="K", linestyle = :solid, color=:brown)
    # savefig(plt, "plots/lidocaine_inibition.pdf")
    display(plt)
end

function pro()
    g(x) = round(100*lidocain_1_8_channel(x), digits=2)
    println(g(1))
    println(g(10))
    println(g(50))
    println(g(100))
    println(g(500))
    println(g(1000))
end

# ------------------- STEADY STATE INHIBITION ------------------- #

Boltzmann_1(V, V_1_2, k, A1) = A1 / ( 1 + exp((V-V_1_2) / k) )

# Differential modulation of Nav1.7 and Nav1.8 peripheral nerve sodium channels by the local anesthetic lidocaine
control_1_7_activation(V) = Boltzmann_1(V, -25.56, -3.75, 1.0)
control_1_7_inactivation(V) = Boltzmann_1(V, -68.38, 4.37, 1.0)
lidocaine_1_7_activation(V) = Boltzmann_1(V, -23.92, -3.89, 1.0)
lidocaine_1_7_inactivation(V) = Boltzmann_1(V, -79.02, 5.52, 1.0)

control_1_8_activation(V) = Boltzmann_1(V, 6.24, -5.73, 1.0)
control_1_8_inactivation(V) = Boltzmann_1(V, -42.72, 9.05, 1.0)
lidocaine_1_8_activation(V) = Boltzmann_1(V, 12.32, -6.63, 1.0)
lidocaine_1_8_inactivation(V) = Boltzmann_1(V, -46.81, 8.07, 1.0)

Boltzmann2(V, A1, V_1_2_1, k1, A2, V_1_2_2, k2) = A1 / ( 1 + exp((V-V_1_2_1) / k1) ) + A2 / ( 1 + exp((V-V_1_2_2) / k2) )

# Lidocaine block of neonatal Nav1.3 is differentially modulated by  co-expression of h1 and h3 subunits
control_1_3(V) = Boltzmann2(V, 0.97, -37.0, 5.6, 0.03, 4.4, 1.9)
lidocain_1_3(V) = Boltzmann2(V, 0.97, -57.7, 8.8, 0.03, 3.6, 1.0)

function plot_ss_inhib()

    V = -130:0.5:10

    plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)", legend=:bottomleft)

    # plot!(plt, V, control_1_7_activation.(V), label="control activation 1.7", linestyle = :solid, color=:purple)
    # plot!(plt, V, control_1_7_inactivation.(V), label="control inactivation 1.7", linestyle = :dash, color=:purple)

    # plot!(plt, V, lidocaine_1_7_activation.(V), label="lidocaine activation 1.7", linestyle = :solid, color=:orange)
    # plot!(plt, V, lidocaine_1_7_inactivation.(V), label="lidocaine inactivation 1.7", linestyle = :dash, color=:orange)

    # plot!(plt, V, ODE_DIV0.m_inf_1_7.(V), label=L"m_{∞} Na 1.7", linestyle = :solid, color=:red)
    # plot!(plt, V, ODE_DIV0.h_inf_1_7.(V), label=L"h_{∞} Na 1.7", linestyle = :dash, color=:red)

    # plot!(plt, V, control_1_8_activation.(V), label="control activation 1.8", linestyle = :solid, color=:purple)
    # plot!(plt, V, control_1_8_inactivation.(V), label="control inactivation 1.8", linestyle = :dash, color=:purple)

    # plot!(plt, V, lidocaine_1_8_activation.(V), label="lidocaine activation 1.8", linestyle = :solid, color=:orange)
    # plot!(plt, V, lidocaine_1_8_inactivation.(V), label="lidocaine inactivation 1.8", linestyle = :dash, color=:orange)

    # plot!(plt, V, ODE_DIV0.m_inf_1_8.(V), label=L"m_{∞} Na 1.8", linestyle = :solid, color=:green)
    # plot!(plt, V, ODE_DIV0.h_inf_1_8.(V), label=L"h_{∞} Na 1.8", linestyle = :dash, color=:green)

    # plot!(plt, V, control_1_3.(V), label="control 1.3", linestyle = :solid, color=:purple)
    # plot!(plt, V, lidocain_1_3.(V), label="lidocaine 1.3", linestyle = :dash, color=:orange)
    # plot!(plt, V, ODE_DIV0.h_inf_1_3.(V), label=L"h_{∞} Na 1.3", linestyle = :dash, color=:blue)

    # savefig(plt, "plots/ss_inhib.pdf")
    display(plt)
end

#plot_ss_inhib()

function plot_conduct_inhib()

    g_nav1p3 = 0.35
    g_nav1p8 = 0.2
    g_nav1p7 = 35.0

    lido_concentrations = 10 .^ range(log10(0.1), log10(2000), length=1000)
    test_point = [1.0, 10.0, 50.0, 100.0, 500.0, 1000.0]
    
    results = get_lidocaine_inhibition.(lido_concentrations)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    plt_1p3 = plot(lido_concentrations, g_nav1p3 .* remaining_1_3, xaxis=:log10, xlabel="Lidocains (µM)", ylabel= "g_nav1p3 (mS/cm2)", label="")
    plt_1p7 = plot(lido_concentrations, g_nav1p7 .* remaining_1_7, xaxis=:log10, xlabel="Lidocains (µM)", ylabel= "g_nav1p7 (mS/cm2)", label="")
    plt_1p8 = plot(lido_concentrations, g_nav1p8 .* remaining_1_8, xaxis=:log10, xlabel="Lidocains (µM)", ylabel= "g_nav1p8 (mS/cm2)", label="")

    results = get_lidocaine_inhibition.(test_point)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    plt_1p3 = scatter!(plt_1p3, test_point, g_nav1p3 .* remaining_1_3, color=:black, marker=:circle, label="")
    plt_1p7 = scatter!(plt_1p7, test_point, g_nav1p7 .* remaining_1_7, color=:black, marker=:circle, label="")
    plt_1p8 = scatter!(plt_1p8, test_point, g_nav1p8 .* remaining_1_8, color=:black, marker=:circle, label="")

    display(plt_1p3)
    display(plt_1p7)
    display(plt_1p8)
    savefig(plt_1p3, "plots/plt_1p3.pdf")
    savefig(plt_1p7, "plots/plt_1p7.pdf")
    savefig(plt_1p8, "plots/plt_1p8.pdf")

end

function plot_ss_shift()

    V = -130:0.5:20

    plt = plot(xlabel="Voltage (mV)", ylabel= "(-)", legendfontsize=7, legend=:bottomright, title="NaV1.3 steady states")

    lido_concentrations = [0.0, 1.0, 10.0, 50.0, 100.0, 500.0, 1000.0]

    with_lido_shift=true
    for (i,C_lido) in enumerate(lido_concentrations)
        plot!(plt, V, ODE.m_inf_1_3.(V; C_lido=C_lido, with_lido_shift=with_lido_shift), label="$C_lido µM", linestyle = :solid, color=palette(:default)[i])
        plot!(plt, V, ODE.h_inf_1_3.(V; with_DIV0 = false, C_lido=C_lido, with_lido_shift=with_lido_shift), label="", linestyle = :dash, color=palette(:default)[i])
    end
    display(plt)
    savefig(plt, "plots/shifted_ss.pdf")
end

plot_conduct_inhib()
#plot_ss_shift()