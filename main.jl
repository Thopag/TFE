using Plots
using ColorSchemes

include("utils.jl")

function smallDRG_DIV0(amp, duration, stim_on, stim_length)

    with_noise = true
    tspan = (0.0, duration)

    # --- Cell Properties --- #

    # Cell Morphology
    r = 11.63                           # [µm] cell radius
    CellArea = 4*pi*(r^2)               # [µm2] cell area (sphere)
    SAV = 3/(r*10^-4)                   # surface area to volume ratio (µm to cm)

    # Cell Capacitance:
    Cr = 17                             # [pF] 
    C = (Cr/CellArea)*100               # [µF/cm^2]

    # Cell Resistance:
    # Rr = 2.5                          # real cell resistance in [GOhms]
    # R = (Rr * CellArea)*10            # model cell resistance in [Ohms*cm^2]

    # Reversal Potential 
    E_Na = 50                            # [mV]
    E_k = -90                            # [mV]
    E_Leak = -62.5                       # [mV] mean RMP of DIV0 neurons = -62.5196 after JP correction(+15mV)

    # **** BASELINE: rheo = 17pA
    g_Leak = 0.025                       #(1/Rr)/CellArea*(10^2); # [mS/cm2] normalized by cell area
    g_AHP =  2.5 
    g_Km = 0.05
    g_Kdr = 3.5 
    beta_z_AHP = 5                      # [mV]
    gamma_z =  4                        # [mV] - same for gAHP and gM
    tau_z = 100

    # ** Na conductances
    g_nav1p3 = 0 
    g_nav1p8 = 30                       # native
    g_nav1p7 = 3                        # native 
    # g_nav1p9 = 0

    # **** PHARMACOLOGY
    # g_nav1p8 = 4                      # 90% block - rheo = 17pA

    # **** DYNAMIC CLAMP EXPERIMENT
    # g_nav1p7 = 40                     # rheo = 6 pA

    # --- Stimulus parameters --- #

    stim_off = stim_on + stim_length    # [ms]

    Ihold = -3
    I0 = (Ihold*(10^-6))/(CellArea*(10^-8))

    I_ext(t) = I0 +  pulse(t,stim_on,stim_off)* ((amp * (10^-6)) / (CellArea * (10^-8)))

    # --- Noise parameters --- #

    mu_noise = 0
    tau_noise = 5                       #(ms)
    sigma_noise = 0.05                  # 0.1 # !sigma(noise) !0.5 uA/cm2

    # --- Set initial values --- #

    u0 = zeros(14)

    u0[1] = -69.5
    u0[2] = 0
    u0[3] = 0
    u0[4] = 0
    u0[5] = 0
    u0[6] = 0
    u0[7] = 0.9952
    u0[8] = 0
    u0[9] = 0.6487
    u0[10] = 0.0014 
    u0[11] = 0
    u0[12] = 0
    u0[13] = 0
    u0[14] = 0.6487 

    # --- Run simulation --- #

    p = (I_ext, C, 
        g_nav1p3, g_nav1p7, g_nav1p8, E_Na,
        g_Kdr, g_Km, g_AHP, E_k,
        g_Leak, E_Leak,
        sigma_noise, mu_noise, tau_noise,
        with_noise)

    print("--------------- Start Simulation ---------------\n")

    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = simulation(u0, tspan, p)

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak = give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)

    print("--------------- End Simulation ---------------\n")

    # --- Plots --- #

    plot(t, V, color= :black, label="")
    xlims!((400, 1700))
    ylims!((-100, 0))
    xlabel!("Time (ms)")
    ylabel!("Voltage (mV)")

    savefig("plots/plot_1.pdf")
    print("plot 1\n")

    plot(V, m7.^3 .* h7 .* 100, color=:green, label="NaV1p7")
    plot!(V, m8.^3 .* h8 .* 100, color=:blue, label="NaV1p8")
    ylabel!("Availability (%)")
    xlabel!("Voltage (mV)")
    plot!(aspect_ratio = 1)

    savefig("plots/plot_2.pdf")
    print("plot 2\n")

    p = plot(layout = (2, 1))
    x_range = (450, 600)

    plot!(p[1], t, V)
    xlims!(p[1], x_range)
    ylims!(p[1], (-100, 50))
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, I_NaV1p3 .+ I_NaV1p7 .+ I_NaV1p8, color=:red, label="Sodium", legend = :topleft)
    plot!(p[2], t, I_Kdr .+ I_Km .+ I_AHP, color=:blue , label="Potassium")
    xlims!(p[2], x_range)
    ylims!(p[2], (-250, 250))
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Current (uA/cm2)")

    savefig(p, "plots/plot_3.pdf")
    print("plot 3\n")
    

    p = plot(layout = (2, 1))
    plot!(p[1], t, m3, label="m3")
    plot!(p[1], t, h3, label="h3")
    plot!(p[1], t, m7, label="m7")
    plot!(p[1], t, h7, label="h7")
    plot!(p[1], t, m8, label="m8")
    plot!(p[1], t, h8, label="h8")
    plot!(p[1], t, ndr, label="ndr")
    plot!(p[1], t, ldr, label="ldr")
    plot!(p[1], t, nm, label="nm")
    plot!(p[1], t, z_AHP, label="z_AHP")
    plot!(legendfontsize=6, legend=:topleft)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    plot!(p[2], t, V, label="V")
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")
    savefig(p, "plots/plot_channels.pdf")
    print("plot channels\n")

    p = plot(layout = (2, 1))
    plot!(p[1], t, ndr, label="ndr")
    plot!(p[2], t, ldr, label="ldr")
    plot!(p[1], t, n_test, label="n_test")
    plot!(p[2], t, l_test, label="l_test")
    plot!(legendfontsize=4, legend=:topleft)
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "(-)")

    """
    plot!(p[2], t, V, label="V")
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Voltage (mV)")
    """
    savefig(p, "plots/plot_l_n_test.pdf")
    print("plot_l_n_test\n")

    return
end

if abspath(PROGRAM_FILE) == @__FILE__
    smallDRG_DIV0(17,1500,500,1000)
end

