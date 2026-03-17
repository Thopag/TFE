

function tau_plot()

    V = -160:0.5:60
    plt_tau = plot(xlabel="Voltage (mV)", ylabel= "- (-)", yaxis=:log10, xlims=(-120, 50), legendfontsize=7, legend=:bottomright)

    plot!(plt_tau, V, ODE_DIV0.tau_m_1_3.(V), label=L"τ_{m} Na 1.3", linestyle = :solid, color=:blue)
    plot!(plt_tau, V, ODE_DIV0.tau_h_1_3.(V), label=L"τ_{h} Na 1.3", linestyle = :dash, color=:blue)

    plot!(plt_tau, V, ODE_DIV0.tau_m_1_7.(V), label=L"τ_{m} Na 1.7", linestyle = :solid, color=:red)
    plot!(plt_tau, V, ODE_DIV0.tau_h_1_7.(V), label=L"τ_{h} Na 1.7", linestyle = :dash, color=:red)

    plot!(plt_tau, V, ODE_DIV0.tau_m_1_8.(V), label=L"τ_{m} Na 1.8", linestyle = :solid, color=:green)
    plot!(plt_tau, V, ODE_DIV0.tau_h_1_8.(V), label=L"τ_{h} Na 1.8", linestyle = :dash, color=:green)

    plot!(plt_tau, V, ODE_DIV0.tau_n_K_M.(V), label=L"τ_{n} K_{M}", linestyle = :solid, color=:purple)

    plot!(plt_tau, V, ODE_DIV0.tau_n_K_dr.(V), label=L"τ_{n} K_{dr}", linestyle = :solid, color=:orange)
    plot!(plt_tau, V, ODE_DIV0.tau_l_K_dr.(V), label=L"τ_{l} K_{dr}", linestyle = :dash, color=:orange)

    plot!(plt_tau, V, ODE_DIV0.tau_z_AHP.(V), label=L"τ_{z_{AHP}}", linestyle = :solid, color=:brown)
    display(plt_tau)
    savefig(plt_tau, "plots/tau_variable.pdf")
end

tau_plot()