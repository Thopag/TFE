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

    Iext(t) = I0 +  pulse(t,stim_on,stim_off)* ((amp * (10^-6)) / (CellArea * (10^-8)))

    # --- Noise parameters --- #

    mu_noise = 0
    tau_noise = 5                       #(ms)
    sigma_noise = 0.05                  # 0.1 # !sigma(noise) !0.5 uA/cm2

    # --- Set initial values --- #

    u0 = zeros(12)

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

    # --- Run simulation --- #

    p = (Iext, C, 
        g_nav1p3, g_nav1p7, g_nav1p8, E_Na,
        g_Kdr, g_Km, g_AHP, E_k,
        g_Leak, E_Leak,
        sigma_noise, mu_noise, tau_noise,
        with_noise)

    print("--------------- Start Simulation ---------------\n")

    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise = simulation(u0, tspan, p)

    INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak = give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)

    print("--------------- End Simulation ---------------\n")

    # --- Plots --- #

    p = plot(t, V, color= :black, label="")
    xlims!((400, 1700))
    ylims!((-100, 0))
    xlabel!("Time (ms)")
    ylabel!("Voltage (mV)")

    display(p)

    savefig("plots/plot_1.pdf")

    plot(V, m7.^3 .* h7 .* 100, color=:green, label="NaV1p7")
    plot!(V, m8.^3 .* h8 .* 100, color=:blue, label="NaV1p8")
    ylabel!("Availability (%)")
    xlabel!("Voltage (mV)")
    plot!(aspect_ratio = 1)

    savefig("plots/plot_2.pdf")

    p = plot(layout = (2, 1))
    x_range = (450, 600)

    plot!(p[1], t, V)
    xlims!(p[1], x_range)
    ylims!(p[1], (-100, 50))
    xlabel!(p[1], "Time (ms)")
    ylabel!(p[1], "Voltage (mV)")

    plot!(p[2], t, INaV1p3 .+ INaV1p7 .+ INaV1p8, color=:red, label="Sodium", legend = :topleft)
    plot!(p[2], t, IKdr .+ IKm .+ IAHP, color=:blue , label="Potassium")
    xlims!(p[2], x_range)
    ylims!(p[2], (-250, 250))
    xlabel!(p[2], "Time (ms)")
    ylabel!(p[2], "Current (uA/cm2)")

    savefig(p, "plots/plot_3.pdf")

    return
end

smallDRG_DIV0(17,1500,500,1000)
