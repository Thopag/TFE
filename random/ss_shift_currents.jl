include("../DIV0/params.jl")
include("../DIV7/params.jl")

function ss_currents(p, V)

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
    with_lido_shift = p.with_lido_shift

    C_lido = p.C_lidocaine

    m3 = ODE.m_inf_1_3.(V; C_lido=C_lido, with_lido_shift=with_lido_shift)
    h3 = ODE.h_inf_1_3.(V; C_lido=C_lido, with_lido_shift=with_lido_shift, with_DIV0=p.with_DIV0)

    m7 = ODE.m_inf_1_7.(V; C_lido=C_lido, with_lido_shift=with_lido_shift)
    h7 = ODE.h_inf_1_7.(V; C_lido=C_lido, with_lido_shift=with_lido_shift)

    m8 = ODE.m_inf_1_8.(V; C_lido=C_lido, with_lido_shift=with_lido_shift)
    h8 = ODE.h_inf_1_8.(V; C_lido=C_lido, with_lido_shift=with_lido_shift)

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
    Iext = p.I0 .+ p.Excitation

    dV_dt = (Iext .- INaV1p3 .- INaV1p7 .- INaV1p8 .- IKdr .- IKm .- ILeak .- IAHP) ./ p.C

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt
    
end

function plot_ss_shift(V, vec, labels; title="title")

    plt = plot(xlabel="Voltage (mV)", ylabel= "(-)", legendfontsize=7, legend=:bottomright, title="$title steady states")
    with_lido_shift=true
    for (i,(value,label)) in enumerate(zip(vec,labels))
        plot!(plt, V, ODE.m_inf_1_7.(V; C_lido=value, with_lido_shift=with_lido_shift), label=label, linestyle = :solid, color=palette(:default)[i])
        plot!(plt, V, ODE.h_inf_1_7.(V; C_lido=value, with_lido_shift=with_lido_shift), label="", linestyle = :dash, color=palette(:default)[i])
    end
    display(plt)
    savefig(plt, "plots/shifted_ss.svg")
end

function plot_ss_current(V, vec, labels; title="title")

    get_param = DIV7_parameter
    amp = 100
    stim_on = 500.0
    stim_length = 1000.0

    ys = (-10,1)

    plt_I = plot(xlabel="Voltage (mV)", ylabel= "Current (uA/cm2)", legendfontsize=7, legend=:bottomleft, title="$title steady state current")

    plt_sum = plot(xlabel="Voltage (mV)", ylabel= "Current (uA/cm2)", legendfontsize=7, legend=:bottomleft, title="$title steady state current sums")
    # plot!(plt_I, ylim=ys)
    # plot!(plt_sum, ylim=ys)

    for (i,(value,label)) in enumerate(zip(vec,labels))
        p = param = get_param(amp, stim_on, stim_length;
            C_lidocaine=value,
            with_lido_shift=true,
            with_inhibition=false,
            )
        INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = ss_currents(p, V)

        # plot!(plt_I, [], [], label=label, color=palette(:default)[i], alpha=1)

        # plot!(plt_I, V, INaV1p3, label="", linestyle=:dot, color=palette(:default)[i], alpha=1)
        # plot!(plt_I, V, INaV1p7, label="", linestyle=:dash, color=palette(:default)[i], alpha=1)
        # plot!(plt_I, V, INaV1p8, label="", color=palette(:default)[i], alpha=1)

        # plot!(plt_I, V, dV_dt, label=label, color=palette(:default)[i], alpha=1)

        plot!(plt_sum, V, INaV1p8 .+ INaV1p7 .+ INaV1p3, label=label, color=palette(:default)[i], alpha=1)
    end

    p_k = param = get_param(amp, stim_on, stim_length;)
    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak, Iext, dV_dt = ss_currents(p_k, V)

    # plot!(plt_I, V, .-IKdr, label=L"- I_{Kdr}", linestyle = :dot, color=:black)
    # plot!(plt_I, V, .-IKm, label=L"- I_{KM}", linestyle = :dash, color=:black)
    # plot!(plt_I, V, .- IAHP, color=:black, label=L"- I_{AHP}")

    plot!(plt_I, V, INaV1p3, label="NaV 1.3", linestyle=:dot, color=:blue, alpha=1)
    plot!(plt_I, V, INaV1p7, label="NaV 1.7", linestyle=:dash, color=:red, alpha=1)
    plot!(plt_I, V, INaV1p8, label="NaV 1.8", color=:green, alpha=1)

    # plot!(plt_I, V, ILeak, color=:black, label=L"I_{Leak}")

    plot!(plt_sum, V, .- IAHP .-IKm .- IKdr, color=:black, label=L"- I_{K}")

    #display(plt_I)
    savefig(plt_I, "plots/ss_current.svg")
    savefig(plt_sum, "plots/sums_ss_current.svg")

end

function main()

    #lido_concentrations = [0.0, 1.0, 10.0, 50.0, 100.0, 500.0, 1000.0]
    #inhibs = [0.0,  0.3, 0.5, 0.9, 0.93, 1.0]

    V = -130.0:0.5:70.0
    shifts = 0.0:2:14.0
    inhibs = 0.0:0.1:1.0

    vec = shifts
    labels = ["$value mV" for value in vec]

    title = ""

    #plot_ss_shift(V, vec, labels; title=title)
    plot_ss_current(V, vec, labels; title=title)
end

main()
