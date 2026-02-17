include("utils.jl")
include("Ploting.jl")

function smallDRG_DIV7(amp, duration, stim_on, stim_length)

    with_noise = true
    tspan = (0.0, duration)

    # --- Cell Properties --- #

    # Cell Morphology
    r = 18.13                           # [µm] cell radius
    CellArea = 4*pi*(r^2)               # [µm2] cell area (sphere)
    SAV = 3/(r*10^-4)                   # surface area to volume ratio (µm to cm)

    # Cell Capacitance:
    Cr = 41.3                           # [pF] 
    C = (Cr/CellArea)*100               # [µF/cm^2]

    # Cell Resistance:
    Rr = 0.7                          # real cell resistance in [GOhms]
    #R = (Rr * CellArea)*10            # model cell resistance in [Ohms*cm^2]

    # Reversal Potential 
    E_Na = 50                            # [mV]
    E_k = -90                            # [mV]
    E_Leak = -70                         # [mV] mean RMP of DIV0 neurons = -62.5196 after JP correction(+15mV)

    # **** BASELINE: rheo = 12pA
    g_Leak = 0.035                       # (1/Rr)/CellArea*(10^2); # [mS/cm2] normalized by cell area
    g_AHP =  2.5 
    g_Km = 0.5
    g_Kdr = 3.5

    # ** Na conductances
    g_nav1p3 = 0.35 
    g_nav1p8 = 0.2                       # native
    g_nav1p7 = 35                        # native 
    # g_nav1p9 = 0

    # **** PHARMACOLOGY
    # g_nav1p3 = 0.035                      # 90% block - rheo = 21pA
    # g_nav1p7 = 10.5                       # 70% block - rheo = 16pA

    # **** DYNAMIC CLAMP EXPERIMENT
    # g_nav1p8 = 40                         # dynamic clamp  48 pA

    # **** INTERCHANGEABILITY
    # g_nav1p7 = 60                         # rheo = 15pA
    # g_nav1p3 = 0.8                        # rheo = 7pA


    # --- Stimulus parameters --- #

    stim_off = stim_on + stim_length    # [ms]

    Ihold = 0
    I0 = (Ihold*(10^-6))/(CellArea*(10^-8))
    Excitation = ((amp * (10^-6)) / (CellArea * (10^-8)))

    I_ext(t) =  I0 +  pulse(t,stim_on,stim_off) * Excitation
    #I_ext(t) = I0 +  pulse(t,500,600) * Excitation + pulse(t,1100,1200) * Excitation

    # --- Noise parameters --- #

    mu_noise = 0
    tau_noise = 5                       # (ms)
    sigma_noise = 0.05                  # 2.5 # !sigma(noise) !0.5 uA/cm2

    # --- Set initial values --- #

    u0 = zeros(14)

    u0[1] = -70         # V
    u0[2] = 0           # m3
    u0[3] = 0.7191      # h3
    u0[4] = 0.0219      # m7
    u0[5] = 0.2579      # h7
    u0[6] = 0           # m8
    u0[7] = 0.9964      # h8
    u0[8] = 0           # ndr
    u0[9] = 0.6058      # ldr
    u0[10] = 0          # nm 
    u0[11] = 0          # z_AHP
    u0[12] = 0          # Inoise

    u0[13] = 0          # n_test
    u0[14] = 0.6487     # l_test

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

    plot_voltage(t, V, amp)
    plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)
    plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)

    return
end

#if abspath(PROGRAM_FILE) == @__FILE__
smallDRG_DIV7(12,1700,500,1000)
#end