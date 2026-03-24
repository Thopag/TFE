
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

# ---- #

Boltzmann2(V, A1, V_1_2_1, k1, A2, V_1_2_2, k2) = A1 / ( 1 + exp((V-V_1_2_1) / k1) ) + A2 / ( 1 + exp((V-V_1_2_2) / k2) )

# Lidocaine block of neonatal Nav1.3 is differentially modulated by  co-expression of h1 and h3 subunits
control_1_3(V) = Boltzmann2(V, 0.97, -37.0, 5.6, 0.03, 4.4, 1.9)
lidocain_1_3(V) = Boltzmann2(V, 0.97, -57.7, 8.8, 0.03, 3.6, 1.0)

# ---- #

Boltzmann_3(V, V_1_2, k) = 1 / ( 1 + exp((V-V_1_2) / (-k)) )

# Gating Properties of Nav1.7 and Nav1.8 Peripheral Nerve Sodium Channels
test_act_1_7(V) =  Boltzmann_3(V, -22.0, 5.4)
test_inact_1_7(V) =  Boltzmann_3(V, -68.2, -6.4)

test_act_1_8(V) =  Boltzmann_3(V, 4.7, 6.8)
test_inact_1_8(V) =  Boltzmann_3(V, -54.8, -8.4)

# Downregulation of Tetrodotoxin-Resistant Sodium Currents and Upregulation of a Rapidly Repriming Tetrodotoxin-Sensitive Sodium Current in Small Spinal Sensory Neurons after Nerve Injury
test2_act_1_8(V) =  Boltzmann_3(V, -15.7, 6.4)
test2_inact_1_8(V) =  Boltzmann_3(V, -30.0, -7.5)

test2_act_1_7(V) =  Boltzmann_3(V, -27.6, 6.4)
test2_inact_1_7(V) =  Boltzmann_3(V, -69.3, -6.4)

function steady_states()

    V = -160:0.5:80

    plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)", xlims=(-160, 80), legend=:bottomright)

    # plot!(plt, V, ODE.m_inf_1_3.(V), label=L"m_{∞} Na 1.3", linestyle = :solid, color=:blue)
    # plot!(plt, V, ODE.h_inf_1_3.(V), label=L"h_{∞} Na 1.3", linestyle = :dash, color=:blue)

    """--------------------------------------------------------------------------------------------------"""

    # plot!(plt, V, ODE.m_inf_1_7.(V; C_lido=0), label=L"Original   m_{∞} Na 1.7", linestyle = :solid, color=:red)
    # plot!(plt, V, ODE.h_inf_1_7.(V), label=L"Original   h_{∞} Na 1.7", linestyle = :dash, color=:red)

    # plot!(plt, V, control_1_7_activation.(V), label=L"Article   m_{∞} Na 1.7", linestyle = :solid, color=:purple)
    # plot!(plt, V, control_1_7_inactivation.(V), label=L"Article   h_{∞} Na 1.7", linestyle = :dash, color=:purple)

    # plot!(plt, V, test_act_1_7.(V), label=L"other Article 1   m_{∞} Na 1.7", linestyle = :dot, color=:red)
    # plot!(plt, V, test_inact_1_7.(V), label=L"other Article 1   h_{∞} Na 1.7", linestyle = :dot, color=:red)

    # plot!(plt, V, test2_act_1_7.(V), label=L"other Article 2   m_{∞} Na 1.7", linestyle = :dashdot, color=:red)
    # plot!(plt, V, test2_inact_1_7.(V), label=L"other Article 2   h_{∞} Na 1.7", linestyle = :dashdot, color=:red)

    """--------------------------------------------------------------------------------------------------"""

    # plot!(plt, V, ODE.m_inf_1_8.(V), label=L"Original   m_{∞} Na 1.8", linestyle = :solid, color=:green)
    # plot!(plt, V, ODE.h_inf_1_8.(V), label=L"Original   h_{∞} Na 1.8", linestyle = :dash, color=:green)

    # plot!(plt, V, control_1_8_activation.(V), label=L"Article   m_{∞} Na 1.8", linestyle = :solid, color=:purple)
    # plot!(plt, V, control_1_8_inactivation.(V), label=L"Article   h_{∞} Na 1.8", linestyle = :dash, color=:purple)

    # plot!(plt, V, test_act_1_8.(V), label=L"other Article 1   m_{∞} Na 1.8", linestyle = :dot, color=:green)
    # plot!(plt, V, test_inact_1_8.(V), label=L"other Article 1   h_{∞} Na 1.8", linestyle = :dot, color=:green)

    # plot!(plt, V, test2_act_1_8.(V), label=L"other Article 2   m_{∞} Na 1.8", linestyle = :dashdot, color=:green)
    # plot!(plt, V, test2_inact_1_8.(V), label=L"other Article 2   h_{∞} Na 1.8", linestyle = :dashdot, color=:green)

    """--------------------------------------------------------------------------------------------------"""

    # plot!(plt, V, ODE.m_inf_1_8.(V), label=L"Original   m_{∞} Na 1.8", linestyle = :solid, color=:green)
    # plot!(plt, V, ODE.h_inf_1_8.(V), label=L"Original   h_{∞} Na 1.8", linestyle = :dash, color=:green)
    # plot!(plt, V, ODE.n_inf_K_M.(V), label=L"n_{∞} K_{M}", linestyle = :solid, color=:purple)
    # plot!(plt, V, ODE.n_inf_K_dr.(V), label=L"n_{∞} K_{dr}", linestyle = :solid, color=:orange)
    # plot!(plt, V, ODE.l_inf_K_dr.(V), label=L"l_{∞} K_{dr}", linestyle = :dash, color=:orange)
    # plot!(plt, V, ODE.z_AHP_inf.(V), label=L"{z_{AHP}}_{∞}", linestyle = :solid, color=:brown)


    """--------------------------------------------------------------------------------------------------"""

    display(plt)
    #savefig(plt, "plots/infinity_variable.pdf")
end

steady_states()