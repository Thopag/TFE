
function DIV0_parameter(amp, stim_on, stim_length; 

    # ** Na conductances
    g_nav1p3 = 0.0,
    g_nav1p8 = 30.0,
    g_nav1p7 = 3.0,

    # ** Leak conducatance
    g_Leak = 0.025,

    # ** K conductance
    g_AHP = 2.5,
    g_Km = 0.05,
    g_Kdr = 3.5,

    # Reversal Potential 
    E_Na = 50.0,                          # [mV]
    E_k = -90.0,                          # [mV]
    E_Leak = -62.5,                       # [mV]

    # Lidocaine
    C_lidocaine = 0,

    # --- Noise parameters --- #

    with_noise = false,

    mu_noise = 0.0,
    tau_noise = 5.0,                       # (ms)
    sigma_noise = 0.05,
    )

    # --- Lidocaine effect --- #

    remaining_1_3, remaining_1_7, remaining_1_8 = get_lidocaine_inhibition(C_lidocaine)

    g_nav1p3 = g_nav1p3*remaining_1_3
    g_nav1p7 = g_nav1p7*remaining_1_7
    g_nav1p8 = g_nav1p8*remaining_1_8
    
    # --- Stimulus parameters --- #

    # Cell Morphology
    r = 11.63                           # [µm] cell radius
    CellArea = 4.0*pi*(r^2)             # [µm2] cell area (sphere)

    # Cell Capacitance:
    Cr = 17.0                           # [pF] 
    C = (Cr/CellArea)*100.0             # [µF/cm^2]

    stim_off = stim_on + stim_length    # [ms]

    Ihold = -3
    I0 = (Ihold*(10^-6))/(CellArea*(10^-8))
    Excitation = ((amp * (10^-6)) / (CellArea * (10^-8)))

    # --- Parameter struct --- #

    p = Parameters(
        I0, stim_on, stim_off, Excitation, C,
        g_nav1p3, g_nav1p7, g_nav1p8, E_Na,
        g_Kdr, g_Km, g_AHP, E_k,
        g_Leak, E_Leak,
        sigma_noise, mu_noise, tau_noise,
        with_noise
    )
    
    return p
end

function DIV0_parameter_default(amp, stim_on, stim_length)

    # --- Cell Properties --- #

    # Cell Morphology
    r = 11.63                           # [µm] cell radius
    CellArea = 4.0*pi*(r^2)               # [µm2] cell area (sphere)
    SAV = 3.0/(r*10^-4)                   # surface area to volume ratio (µm to cm)

    # Cell Capacitance:
    Cr = 17.0                             # [pF] 
    C = (Cr/CellArea)*100.0               # [µF/cm^2]

    # Cell Resistance:
    #Rr = 2.5                          # real cell resistance in [GOhms]
    #R = (Rr * CellArea)*10            # model cell resistance in [Ohms*cm^2]

    # Reversal Potential 
    E_Na = 50.0                          # [mV]
    E_k = -90.0                          # [mV]
    E_Leak = -62.5                       # [mV] mean RMP of DIV0 neurons = -62.5196 after JP correction(+15mV)

    # **** BASELINE: rheo = 17pA
    g_Leak = 0.025                       # (1/Rr)/CellArea*(10^2); # [mS/cm2] normalized by cell area
    g_AHP = 2.5 
    g_Km = 0.05
    g_Kdr = 3.5 

    # ** Na conductances
    g_nav1p3 = 0.0 
    g_nav1p8 = 30.0                       # native
    g_nav1p7 = 3.0                        # native 
    # g_nav1p9 = 0.0

    # **** PHARMACOLOGY
    # g_nav1p8 = 4.0                      # 90% block - rheo = 17pA

    # **** DYNAMIC CLAMP EXPERIMENT
    # g_nav1p7 = 40.0                     # rheo = 6 pA

    # --- Stimulus parameters --- #

    stim_off = stim_on + stim_length    # [ms]

    Ihold = -3
    I0 = (Ihold*(10^-6))/(CellArea*(10^-8))
    Excitation = ((amp * (10^-6)) / (CellArea * (10^-8)))

    # --- Noise parameters --- #

    with_noise = false

    mu_noise = 0.0
    tau_noise = 5.0                       # (ms)
    sigma_noise = 0.05                  # 0.1 # !sigma(noise) !0.5 uA/cm2

    # --- Parameter struct --- #

    p = Parameters(
        I0, stim_on, stim_off, Excitation, C,
        g_nav1p3, g_nav1p7, g_nav1p8, E_Na,
        g_Kdr, g_Km, g_AHP, E_k,
        g_Leak, E_Leak,
        sigma_noise, mu_noise, tau_noise,
        with_noise
    )
    
    return p
end

function DIV0_u0()

    u0 = zeros(14)

    u0[1] = -69.5         # V
    u0[2] = 0.0           # m3
    u0[3] = 0.0           # h3
    u0[4] = 0.0           # m7
    u0[5] = 0.0           # h7
    u0[6] = 0.0           # m8
    u0[7] = 0.9952        # h8
    u0[8] = 0.0           # ndr
    u0[9] = 0.6487        # ldr
    u0[10] = 0.0014       # nm 
    u0[11] = 0.0          # z_AHP
    u0[12] = 0.0          # Inoise

    u0[13] = 0.0          # n_test
    u0[14] = 0.6487       # l_test

    return u0
end
