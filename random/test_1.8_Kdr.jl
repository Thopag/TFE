

function x_inf(V, alpha, beta)
    return alpha(V) / (alpha(V) + beta(V))
end

function tau_x(V, alpha, beta)
    return 1 / (alpha(V) + beta(V))
end
# ------------------------ #
function alpha_m_model(V)
    return 7.21/(1+exp((V-(0.063-5.3))/-7.86))
end

function alpha_h_model(V)
    return 1.63/(1+exp((V-(-68.5-5.3))/10.01))
end

function beta_m_model(V)
    return 7.4/(1+exp((V-(-53.06-5.3))/19.34))
end

function beta_h_model(V)
    return 0.81/(1+exp((V-(11.44-5.3))/-13.12))
end

# ------------------------ #

function alpha_m_rat(V)
    return 7.21-7.21/(1+exp((V-(0.063-5.3))/7.86))
end

function alpha_h_rat(V)
    return 0.003+1.63/(1+exp((V-(-68.5-5.3))/10.01))
end

function beta_m_rat(V)
    return 7.4/(1+exp((V-(-53.06-5.3))/19.34))
end

function beta_h_rat(V)
    return 0.81-0.81/(1+exp((V-(11.44-5.3))/13.12))
end

# ------------------------ #

function alpha_m_human(V)
    return 7.35-7.35/(1+exp((V-(-1.38-5.3))/10.9))
end

function alpha_h_human(V)
    return 0.011+1.39/(1+exp((V-(-78.04-5.3))/11.32))
end

function beta_m_human(V)
    return 5.97/(1+exp((V-(-56.43-5.3))/18.26))
end

function beta_h_human(V)
    return 0.56-0.56/(1+exp((V-(21.82-5.3))/20.03))
end

# ------------------------ #

function alpha_n(V)
    return exp(-5*10^(-3)*(V+32)*9.648*10^4/(8.315*(273.16+25)))/2562.35
end

function alpha_l(V)
    return exp(2*10^(-3)*(V+61)*9.648*10^4/(8.315*(273.16+25)))/2562.35
end

function beta_n(V)
    return exp(-2*10^(-3)*(V+32)*9.648*10^4/(8.315*(273.16+25)))/2562.35
end

function beta_l(V)
    return exp(-2*10^(-3)*(V+32)*9.648*10^4/(8.315*(273.16+25)))/2562.35
end

# ------------------------ #

function main()
    V = -130:0.5:70

    plt = plot(xlabel="Voltage (mV)", legend=:topleft, yaxis=:log10)
    # plot!(plt, V, x_inf.(V, alpha_m_model, beta_m_model), label="1.8 model", color=:green)
    # plot!(plt, V, x_inf.(V, alpha_m_rat, beta_m_rat), label="1.8 article rat", color=:blue)
    # plot!(plt, V, x_inf.(V, alpha_m_human, beta_m_human), label="1.8 article human", color=:red)

    # plot!(plt, V, x_inf.(V, alpha_h_model, beta_h_model), linestyle=:dash, label="", color=:green)
    # plot!(plt, V, x_inf.(V, alpha_h_rat, beta_h_rat), linestyle=:dash, label="", color=:blue)
    # plot!(plt, V, x_inf.(V, alpha_h_human, beta_h_human), linestyle=:dash, label="", color=:red)

    # plot!(plt, V, tau_x.(V, alpha_m_model, beta_m_model), label="1.8 model", color=:green)
    # plot!(plt, V, tau_x.(V, alpha_m_rat, beta_m_rat), label="1.8 article rat", color=:blue)
    # plot!(plt, V, tau_x.(V, alpha_m_human, beta_m_human), label="1.8 article human", color=:red)

    # plot!(plt, V, tau_x.(V, alpha_h_model, beta_h_model), linestyle=:dash, label="", color=:green)
    # plot!(plt, V, tau_x.(V, alpha_h_rat, beta_h_rat), linestyle=:dash, label="", color=:blue)
    # plot!(plt, V, tau_x.(V, alpha_h_human, beta_h_human), linestyle=:dash, label="", color=:red)

    # plot!(plt, V, ODE.n_inf_K_dr.(V), label="Kdr model", color=:green)
    # plot!(plt, V, x_inf.(V, alpha_n, beta_n), label="Kdr article", color=:red)
    # plot!(plt, V, x_inf.(V, ODE.alpha_n_K_dr, ODE.beta_n_K_dr), label="Kdr test", color=:blue)

    # plot!(plt, V, ODE.l_inf_K_dr.(V), linestyle=:dash, label="", color=:green)
    # plot!(plt, V, x_inf.(V, alpha_l, beta_l), linestyle=:dash, label="", color=:red)
    # plot!(plt, V, x_inf.(V, ODE.alpha_l_K_dr, ODE.beta_l_K_dr), linestyle=:dash, label="", color=:blue)

    plot!(plt, V, ODE.tau_n_K_dr.(V), label="Kdr model", color=:green)
    plot!(plt, V, tau_x.(V, alpha_n, beta_n), label="Kdr article", color=:red)

    plot!(plt, V, ODE.tau_l_K_dr.(V), linestyle=:dash, label="", color=:green)
    plot!(plt, V, tau_x.(V, alpha_l, beta_l), linestyle=:dash, label="", color=:red)

    # plot!(plt, V, ODE.beta_n_K_dr.(V), label="Kdr model", color=:green)
    # plot!(plt, V, beta_n.(V), label="Kdr article", color=:red)

    display(plt)
    savefig(plt, "plots/test.pdf")

end

main()