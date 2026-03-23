include("../DIV0/params.jl")
include("../DIV7/params.jl")

V = -80.0:0.5:70.0

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
    with_original=p.with_original

    m3 = ODE.m_inf_1_3.(V; with_original=with_original)
    h3 = ODE.h_inf_1_3.(V; with_DIV0=p.with_DIV0, with_original=with_original)

    m7 = ODE.m_inf_1_7.(V; with_original=with_original)
    h7 = ODE.h_inf_1_7.(V; with_original=with_original)

    m8 = ODE.m_inf_1_8.(V; with_original=with_original)
    h8 = ODE.h_inf_1_8.(V; with_original=with_original)

    nm = ODE.n_inf_K_M.(V)

    ndr = ODE.n_inf_K_dr.(V)
    ldr = ODE.l_inf_K_dr.(V)

    z_AHP = ODE.z_AHP_inf.(V)

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak
    
end

function main()

    get_param = DIV0_parameter
    amp = 17
    stim_on = 500.0
    stim_length = 1000.0

    plt_I = plot(xlabel="Voltage (mV)", ylabel= "Current (uA/cm2)", legendfontsize=7, legend=:bottomright)

    p = get_param(amp, stim_on, stim_length;
        with_original=true)
    
    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak = ss_currents(p)

    plot!(plt_I, V, INaV1p3, color=:blue, label=L"I_{NaV1.3}")
    plot!(plt_I, V, INaV1p7, color=:red, label=L"I_{NaV1.7}")
    plot!(plt_I, V, INaV1p8, color=:green, label=L"I_{NaV1.8}")
    
    # plot!(plt_I, V, IKdr, color=:orange, label=L"I_{Kdr}")
    # plot!(plt_I, V, IKm, color=:purple, label=L"I_{KM}")
    # plot!(plt_I, V, IAHP, color=:brown, label=L"I_{AHP}")

    # plot!(plt_I, V, ILeak, color=:black, label=L"I_{Leak}")
    
    p = get_param(amp, stim_on, stim_length;
        g_nav1p7 = 33000.0,
        with_original=false)

    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak = ss_currents(p)

    plot!(plt_I, V, INaV1p3, color=:blue, linestyle=:dash, label=L"I_{NaV1.3} article")
    plot!(plt_I, V, INaV1p7, color=:red, linestyle=:dash, label=L"I_{NaV1.7} article")
    plot!(plt_I, V, INaV1p8, color=:green, linestyle=:dash, label=L"I_{NaV1.8} article")

    display(plt_I)
    savefig(plt_I, "plots/ss_current.pdf")

end

main()

