export DIV0_u0, DIV0_parameter

function DIV0_parameter(amp;
    
    stim_on = 500.0,                # [ms]
    stim_length = 1000.0,           # [ms]

    # ** Na conductances
    g_nav1p3 = 0.0,                 # [mS/cm2]
    g_nav1p7 = 3.0,
    g_nav1p8 = 30.0,

    # ** Leak conducatance
    g_Leak = 0.025,

    # ** K conductance
    g_Kdr = 3.5,
    g_Km = 0.05,
    g_AHP = 2.5,

    # Reversal Potential 
    E_Na = 50.0,                          # [mV]
    E_k = -90.0,                          # [mV]
    E_Leak = -62.5,                       # [mV]

    # Lidocaine
    C_lidocaine = 0.0,

    # --- Noise parameters --- #

    with_noise = false,

    mu_noise = 0.0,
    tau_noise = 5.0,                       # (ms)
    sigma_noise = 0.05,
    )

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

    Ihold = -3              # [pA] 
    I0 = (Ihold*(10^-6))/(CellArea*(10^-8))                 # [µA/cm^2] 
    Excitation = ((amp * (10^-6)) / (CellArea * (10^-8)))   # [µA/cm^2]

    # --- Parameter struct --- #

    p = Model_Parameters(
        amp, CellArea, I0, stim_on, stim_off, Excitation, C,
        g_nav1p3, g_nav1p7, g_nav1p8, E_Na,
        g_Kdr, g_Km, g_AHP, E_k,
        g_Leak, E_Leak,
        sigma_noise, mu_noise, tau_noise,
        with_noise, C_lidocaine
    )
    
    return p
end

function DIV0_u0()

    u0 = zeros(12)

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

    return u0
end