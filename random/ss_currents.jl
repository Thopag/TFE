include("../DIV0/params.jl")
include("../DIV7/params.jl")

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

    m3 = ODE_DIV0.m_inf_1_3.(V)
    h3 = ODE_DIV0.h_inf_1_3.(V)

    m7 = ODE_DIV0.m_inf_1_7.(V)
    h7 = ODE_DIV0.h_inf_1_7.(V)

    m8 = ODE_DIV0.m_inf_1_8.(V)
    h8 = ODE_DIV0.h_inf_1_8.(V)

    nm = ODE_DIV0.n_inf_K_M.(V)

    ndr = ODE_DIV0.n_inf_K_dr.(V)
    ldr = ODE_DIV0.l_inf_K_dr.(V)

    z_AHP = ODE_DIV0.z_AHP_inf.(V)

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

V = -60:0.5:0
ss_currents(p)