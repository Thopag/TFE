
function steady_state_gate_functions()

    V = -120:0.5:60

    xticks = [-120, -90, -60, -30, 0, 30, 60]
    plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)", legend=:bottomright, legendfontsize=11
                    , xticks = xticks)

    plot!(plt, V, ODE.m_inf_1_3.(V), label=L"m_{3, ∞}", linestyle = :solid, color=:blue)
    plot!(plt, V, ODE.h_inf_1_3.(V), label=L"h_{3, ∞}", linestyle = :dash, color=:blue)

    plot!(plt, V, ODE.m_inf_1_7.(V), label=L"m_{7, ∞}", linestyle = :solid, color=:red)
    plot!(plt, V, ODE.h_inf_1_7.(V), label=L"h_{7, ∞}", linestyle = :dash, color=:red)

    plot!(plt, V, ODE.m_inf_1_8.(V), label=L"m_{8, ∞}", linestyle = :solid, color=:green)
    plot!(plt, V, ODE.h_inf_1_8.(V), label=L"h_{8, ∞}", linestyle = :dash, color=:green)

    plot!(plt, V, ODE.n_inf_K_dr.(V), label=L"n_{dr, ∞}", linestyle = :solid, color=:orange)
    plot!(plt, V, ODE.l_inf_K_dr.(V), label=L"l_{dr, ∞}", linestyle = :dash, color=:orange)
    plot!(plt, V, ODE.n_inf_K_M.(V), label=L"n_{M, ∞}", linestyle = :solid, color=:purple)
    plot!(plt, V, ODE.z_AHP_inf.(V), label=L"z_{AHP, ∞}", linestyle = :solid, color=:brown)

    #display(plt)
    savefig(plt, "plots/report/steady_state_gate_functions.pdf")
end

steady_state_gate_functions()

function tau_gate_functions()

    V = -120:0.5:60

    xticks = [-120, -90, -60, -30, 0, 30, 60]
    yticks = [10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3]
    plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)", legend=:topright, legendfontsize=9
                    , yaxis=:log10, yticks = yticks, xticks = xticks)

    plot!(plt, V, ODE.tau_m_1_3.(V), label=L"τ_{m_{3}}", linestyle = :solid, color=:blue)
    plot!(plt, V, ODE.tau_h_1_3.(V), label=L"τ_{h_{3}}", linestyle = :dash, color=:blue)

    plot!(plt, V, ODE.tau_m_1_7.(V), label=L"τ_{m_{7}}", linestyle = :solid, color=:red)
    plot!(plt, V, ODE.tau_h_1_7.(V), label=L"τ_{h_{7}}", linestyle = :dash, color=:red)

    plot!(plt, V, ODE.tau_m_1_8.(V), label=L"τ_{m_{8}}", linestyle = :solid, color=:green)
    plot!(plt, V, ODE.tau_h_1_8.(V), label=L"τ_{h_{8}}", linestyle = :dash, color=:green)

    plot!(plt, V, ODE.tau_n_K_dr.(V), label=L"τ_{n_{dr}}", linestyle = :solid, color=:orange)
    plot!(plt, V, ODE.tau_l_K_dr.(V), label=L"τ_{l_{dr}}", linestyle = :dash, color=:orange)
    plot!(plt, V, ODE.tau_n_K_M.(V), label=L"τ_{n_{M}}", linestyle = :solid, color=:purple)
    plot!(plt, V, ODE.tau_z_AHP.(V), label=L"τ_{z_{AHP}}", linestyle = :solid, color=:brown)

    #display(plt)
    savefig(plt, "plots/report/tau_gate_functions.pdf")
end

tau_gate_functions()