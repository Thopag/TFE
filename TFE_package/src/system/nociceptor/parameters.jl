export DIV0_parameter, DIV7_parameter

struct NociceptorParameters
    C::Float64
    CellArea::Float64
    E_Na::Float64
    g_NaV1p3::Float64
    g_NaV1p7::Float64
    g_NaV1p8::Float64
    E_K::Float64
    g_K_dr::Float64
    g_K_M::Float64
    g_K_AHP::Float64
    E_Leak::Float64
    g_Leak::Float64
end

function DIV0_parameter(;

    # Na conductances
    g_NaV1p3 = 0.0,                 # [mS/cm2]
    g_NaV1p7 = 3.0,
    g_NaV1p8 = 30.0,

    # Leak conducatance
    g_Leak = 0.025,

    # K conductance
    g_K_dr = 3.5,
    g_K_M = 0.05,
    g_K_AHP = 2.5,

    # Reversal Potential 
    E_Na = 50.0,                          # [mV]
    E_K = -90.0,                          # [mV]
    E_Leak = -62.5,                       # [mV]
    )
 
    # --- Stimulus parameters --- #

    # Cell Morphology
    r = 11.63                           # [µm] cell radius
    CellArea = 4.0*pi*(r^2)             # [µm2] cell area (sphere)

    # Cell Capacitance:
    Cr = 17.0                           # [pF] 
    C = (Cr/CellArea)*100.0             # [µF/cm^2]

    # --- Parameter struct --- #

    nociceptor = NociceptorParameters(
        C, CellArea,
        E_Na, g_NaV1p3, g_NaV1p7, g_NaV1p8,
        E_K, g_K_dr, g_K_M, g_K_AHP,
        E_Leak, g_Leak
    )

    return nociceptor
end

function DIV7_parameter(;

    # Na conductances
    g_NaV1p3 =  0.35,                 # [mS/cm2]
    g_NaV1p7 = 35.0,
    g_NaV1p8 = 0.2,

    # Leak conductance
    g_Leak = 0.035,

    # K conductances
    g_K_dr = 3.5,
    g_K_M = 0.5,
    g_K_AHP =  2.5,

    # Reversal Potential 
    E_Na = 50.0,                            # [mV]
    E_K = -90.0,                            # [mV]
    E_Leak = -70.0,                         # [mV]
    )

    # --- Stimulus parameters --- #

    # Cell Morphology
    r = 18.13                           # [µm] cell radius
    CellArea = 4*pi*(r^2)               # [µm2] cell area (sphere)

    # Cell Capacitance:
    Cr = 41.3                           # [pF] 
    C = (Cr/CellArea)*100               # [µF/cm^2]

    # --- Parameter struct --- #

    nociceptor = NociceptorParameters(
        C, CellArea,
        E_Na, g_NaV1p3, g_NaV1p7, g_NaV1p8,
        E_K, g_K_dr, g_K_M, g_K_AHP,
        E_Leak, g_Leak
    )
    
    return nociceptor
end
