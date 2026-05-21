
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

#steady_state_gate_functions()

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

#tau_gate_functions()

function shifted_steady_state_gate_functions()

    V = -120:0.5:60
    shifts = 0.0:5:25.0
    reds, blues, greens, greys = sodium_palettes(length(shifts))

    xticks = [-120, -90, -60, -30, 0, 30, 60]
    plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)", legend=:bottomright, legendfontsize=11
                    , xticks = xticks)

    plot!(plt, [], [], label=L"m_{3, ∞}", linestyle = :solid, color=:blue)
    plot!(plt, [], [], label=L"h_{3, ∞}", linestyle = :dash, color=:blue)

    for (s, c) in zip(shifts,blues)
        plot!(plt, V, ODE.m_inf_1_3.(V; C_lido=s), label="", linestyle = :solid, color=c)
        plot!(plt, V, ODE.h_inf_1_3.(V; C_lido=s), label="", linestyle = :dash, color=c)
    end

    #display(plt)
    savefig(plt, "plots/report/shifted_steady_state_gate_functions.pdf")
end

#shifted_steady_state_gate_functions()

function steady_state_channel_availability()

    V = -120:0.5:60
    E_Na = 50.0
    E_k = -90.0

    xticks = [-120, -90, -60, -30, 0, 30, 60]

    m3 = ODE.m_inf_1_3.(V)
    h3 = ODE.h_inf_1_3.(V)

    m7 = ODE.m_inf_1_7.(V)
    h7 = ODE.h_inf_1_7.(V)

    m8 = ODE.m_inf_1_8.(V)
    h8 = ODE.h_inf_1_8.(V)

    nm = ODE.n_inf_K_M.(V)

    ndr = ODE.n_inf_K_dr.(V)
    ldr = ODE.l_inf_K_dr.(V)

    z_AHP = ODE.z_AHP_inf.(V)

    Na_1p3 = (m3.^3) .* h3 .* (V .- E_Na)
    Na_1p7 = (m7.^3) .* h7 .* (V .- E_Na)
    Na_1p8 = (m8.^3) .* h8 .* (V .- E_Na)
    Kdr = (ndr.^3) .* ldr .* (V .- E_k)
    Km = nm .* (V .- E_k)
    KAHP = (z_AHP.^1) .* (V .- E_k)

    plt = plot(xlabel="Voltage (mV)", ylabel= "Normed Channel Availability (-)", legend=:topleft, legendfontsize=7
                    , xticks = xticks, size = (600, 300), left_margin = 5mm, bottom_margin = 5mm, margin = 5mm)

    plot!(plt, V, Na_1p3 ./ maximum(abs.(Na_1p3)), label=L"NaV1.3", linestyle = :solid, color=:blue, linewidth = 3)

    plot!(plt, V, Na_1p7 ./ maximum(abs.(Na_1p7)), label=L"NaV1.7", linestyle = :solid, color=:red, linewidth = 3)

    plot!(plt, V, Na_1p8 ./ maximum(abs.(Na_1p8)), label=L"NaV1.8", linestyle = :solid, color=:green, linewidth = 3)

    plot!(plt, V, Kdr ./ maximum(abs.(Kdr)), label=L"K_{dr}", linestyle = :solid, color=:orange, linewidth = 3)
    plot!(plt, V, Km ./ maximum(abs.(Km)), label=L"K_{M}", linestyle = :solid, color=:purple, linewidth = 3)
    plot!(plt, V, KAHP ./ maximum(abs.(KAHP)), label=L"K_{AHP}", linestyle = :solid, color=:brown, linewidth = 3)

    #display(plt)
    savefig(plt, "plots/report/steady_state_channels.pdf")
end

#steady_state_channel_availability()

function shifted_channel_availability()

    TFE.with_shift = true
    TFE.with_inhibition = false
    TFE.linear_mode = true

    V = -120:0.5:60
    shifts = 0.0:5:25.0
    E_Na = 50.0
    E_k = -90.0

    xticks = [-120, -90, -60, -30, 0, 30, 60]

    m(shift) = ODE.m_inf_1_3.(V; C_lido=shift)
    h(shift) = ODE.h_inf_1_3.(V; C_lido=shift)
    TFE.shift_inact_1p3 = 1.0

    Na_channel(shift) = (m(shift).^3) .* h(shift)
    max = maximum(abs.(Na_channel(0.0)))

    plt = plot(xlabel="Voltage (mV)", ylabel= "Normed Channel Availability (-)", legend=:topleft, legendfontsize=7
                    , xticks = xticks, size = (400, 300), left_margin = 5mm, bottom_margin = 5mm, margin = 5mm)

    reds, blues, greens, greys = sodium_palettes(length(shifts))

    yticks = []
    for (s,c) in zip(shifts,blues)
        plot!(plt, V, Na_channel(s) ./ max, label="$s mV", linestyle = :solid, color=c)
        tick = maximum(abs.(Na_channel(s))) / max
        if tick >= 0.15
            push!(yticks, round(tick,digits=2))
        end
    end

    plot!(plt, yticks = yticks)
    #display(plt)
    savefig(plt, "plots/report/shifted_channels.pdf")
end

shifted_channel_availability()