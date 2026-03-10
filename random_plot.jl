include("DIV0/params.jl")
include("DIV7/params.jl")

function steady_states()
    plt_inf = plot(xlabel="Voltage (mV)", ylabel= "- (-)", xlims=(-120, 50), legend=:bottomright)

    plot!(plt_inf, V, ODE_DIV7.m_inf_1_3.(V), label=L"m_{∞} Na 1.3", linestyle = :solid, color=:blue)
    plot!(plt_inf, V, ODE_DIV7.h_inf_1_3.(V), label=L"h_{∞} Na 1.3", linestyle = :dash, color=:blue)

    plot!(plt_inf, V, ODE_DIV7.m_inf_1_7.(V), label=L"m_{∞} Na 1.7", linestyle = :solid, color=:red)
    plot!(plt_inf, V, ODE_DIV7.h_inf_1_7.(V), label=L"h_{∞} Na 1.7", linestyle = :dash, color=:red)

    plot!(plt_inf, V, ODE_DIV7.m_inf_1_8.(V), label=L"m_{∞} Na 1.8", linestyle = :solid, color=:green)
    plot!(plt_inf, V, ODE_DIV7.h_inf_1_8.(V), label=L"h_{∞} Na 1.8", linestyle = :dash, color=:green)

    plot!(plt_inf, V, ODE_DIV7.n_inf_K_M.(V), label=L"n_{∞} K_{M}", linestyle = :solid, color=:purple)

    plot!(plt_inf, V, ODE_DIV7.n_inf_K_dr.(V), label=L"n_{∞} K_{dr}", linestyle = :solid, color=:orange)
    plot!(plt_inf, V, ODE_DIV7.l_inf_K_dr.(V), label=L"l_{∞} K_{dr}", linestyle = :dash, color=:orange)

    plot!(plt_inf, V, ODE_DIV7.z_AHP_inf.(V), label=L"{z_{AHP}}_{∞}", linestyle = :solid, color=:brown)
    display(plt_inf)
    savefig(plt_inf, "plots/infinity_variable.pdf")
end

function ss_currents(p)

    g_nav1p3 = p.g_nav1p3
    g_nav1p7 = p.g_nav1p7
    g_nav1p8 = p.g_nav1p8
    E_Na = p.E_Na

    g_Kdr = p.g_Kdr
    g_Km = p.g_Km
    g_AHP = p.g_AHP
    E_k = p.E_k

    g_Leak = p.g_Leak
    E_Leak = p.E_Leak

    m3 = ODE_DIV7.m_inf_1_3.(V)
    h3 = ODE_DIV7.h_inf_1_3.(V)

    m7 = ODE_DIV7.m_inf_1_7.(V)
    h7 = ODE_DIV7.h_inf_1_7.(V)

    m8 = ODE_DIV7.m_inf_1_8.(V)
    h8 = ODE_DIV7.h_inf_1_8.(V)

    nm = ODE_DIV7.n_inf_K_M.(V)

    ndr = ODE_DIV7.n_inf_K_dr.(V)
    ldr = ODE_DIV7.l_inf_K_dr.(V)

    z_AHP = ODE_DIV7.z_AHP_inf.(V)

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)

    plt_I = plt_tau = plot(xlabel="Voltage (mV)", ylabel= "Current (uA/cm2)", legendfontsize=7, legend=:topleft)
    
    plot!(plt_I, V, INaV1p3, color=:blue, label=L"I_{NaV1.3}")
    plot!(plt_I, V, INaV1p7, color=:red, label=L"I_{NaV1.7}")
    plot!(plt_I, V, INaV1p8, color=:green, label=L"I_{NaV1.8}")

    plot!(plt_I, V, IKdr, color=:orange, label=L"I_{Kdr}")
    plot!(plt_I, V, IKm, color=:purple, label=L"I_{KM}")
    plot!(plt_I, V, IAHP, color=:brown, label=L"I_{AHP}")

    plot!(plt_I, V, ILeak, color=:black, label=L"I_{Leak}")

    display(plt_I)
    savefig(plt_I, "plots/ss_current.pdf")
    
end

function tau_s()
    plt_tau = plot(xlabel="Voltage (mV)", ylabel= "- (-)", yaxis=:log10, xlims=(-120, 50), legendfontsize=7, legend=:bottomright)

    plot!(plt_tau, V, ODE_DIV7.tau_m_1_3.(V), label=L"τ_{m} Na 1.3", linestyle = :solid, color=:blue)
    plot!(plt_tau, V, ODE_DIV7.tau_h_1_3.(V), label=L"τ_{h} Na 1.3", linestyle = :dash, color=:blue)

    plot!(plt_tau, V, ODE_DIV7.tau_m_1_7.(V), label=L"τ_{m} Na 1.7", linestyle = :solid, color=:red)
    plot!(plt_tau, V, ODE_DIV7.tau_h_1_7.(V), label=L"τ_{h} Na 1.7", linestyle = :dash, color=:red)

    plot!(plt_tau, V, ODE_DIV7.tau_m_1_8.(V), label=L"τ_{m} Na 1.8", linestyle = :solid, color=:green)
    plot!(plt_tau, V, ODE_DIV7.tau_h_1_8.(V), label=L"τ_{h} Na 1.8", linestyle = :dash, color=:green)

    plot!(plt_tau, V, ODE_DIV7.tau_n_K_M.(V), label=L"τ_{n} K_{M}", linestyle = :solid, color=:purple)

    plot!(plt_tau, V, ODE_DIV7.tau_n_K_dr.(V), label=L"τ_{n} K_{dr}", linestyle = :solid, color=:orange)
    plot!(plt_tau, V, ODE_DIV7.tau_l_K_dr.(V), label=L"τ_{l} K_{dr}", linestyle = :dash, color=:orange)

    plot!(plt_tau, V, ODE_DIV7.tau_z_AHP.(V), label=L"τ_{z_{AHP}}", linestyle = :solid, color=:brown)
    display(plt_tau)
    savefig(plt_tau, "plots/tau_variable.pdf")
end

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

    plot!(plt, D, lidocain_1_7_resting_inib.(D) .* 100, label="NaV 1.7 resting", linestyle = :dot, color=:red)
    plot!(plt, D, lidocain_1_7_inact_inib.(D) .* 100, label="NaV 1.7 inact", linestyle = :dash, color=:red)
    plot!(plt, D, lidocain_1_7_channel.(D) .* 100, label="NaV 1.7 channel", linestyle = :solid, color=:red)

    plot!(plt, D, lidocain_1_3_resting_inib.(D) .* 100, label="NaV 1.3 resting", linestyle = :dot, color=:blue)
    plot!(plt, D, lidocain_1_3_inact_inib.(D) .* 100, label="NaV 1.3 inact", linestyle = :dash, color=:blue)

    plot!(plt, D, lidocain_1_8_channel.(D) .* 100, label="NaV 1.8 channel", linestyle = :solid, color=:green)

    plot!(plt, D, lidocain_Na.(D) .* 100, label="Na", linestyle = :solid, color=:purple)
    plot!(plt, D, lidocain_K.(D) .* 100, label="K", linestyle = :solid, color=:brown)
    # savefig(plt, "plots/lidocaine_inibition.pdf")
end

get_param = DIV7_parameter
amp = 17
stim_on = 500.0
stim_length = 1000.0

p = get_param(amp, stim_on, stim_length;

        # g_nav1p8 = 4.0 # PHARMACOLOGY DIV0
        # ,g_nav1p7 = 40.0 # dynamic clamp DIV0

        # ,g_nav1p7 = 10.5  # PHARMACOLOGY DIV7
        # ,g_nav1p8 = 40.0  # dynamic clamp DIV7
    )

V = -150:0.5:60
# plot_hill()
# steady_states()
# tau_s()

V = -60:0.5:0
ss_currents(p)
