export projection_neuron_parameter

struct ProjectionNeuronParameters
    C::Float64
    d::Float64
    CellArea::Float64
    Ca_0::Float64
    tau_Ca::Float64
    k::Float64
    g_Na::Float64
    g_K_dr::Float64
    g_K_ir::Float64
    g_K_M::Float64
    g_Leak::Float64
    pLf::Float64
    pLs::Float64
    E_Na::Float64
    E_K::Float64
    E_Leak::Float64
    F::Float64
end

function projection_neuron_parameter(;

    # conductances
    g_Na = 30.0,         # [mS/cm^2]
    g_K_dr = 4.0,        # [mS/cm^2]
    g_K_ir = 0.02,       # [mS/cm^2]
    g_K_M = 0.0,         # [mS/cm^2]
    g_Leak = 0.03268,    # [mS/cm^2]

    pLf = 0.0 * 1.5 * 10^(-4),           # [cm*s^-1]
    pLs = 1000 * 0.2 * 10^(-4),           # [cm*s^-1]

    # Ca
    k = 1.0e4,                     # [µm.cm^(-1)] 
    Ca_0 = 5.0e-5,                 # [mM]
    tau_Ca = 2.0,                  # [ms]

    # Reversal Potential 
    E_Na = 50.0,         # [mV]
    E_K = -70.0,         # [mV]
    E_Leak = -65.0,       # [mV]

    C = 1.0,                # [µF/cm^2]
    d = 0.1,                # [µm]
    )

    L = 20                 # [µm]
    D = 20                 # [µm]
    CellArea = 2.0*pi*(D/2)*L

    F = 96480.0            # [C/mol]

    projection_neuron = ProjectionNeuronParameters(
        C, d, CellArea,
        Ca_0, tau_Ca, k,
        g_Na, g_K_dr, g_K_ir, g_K_M, g_Leak,
        pLf, pLs,
        E_Na, E_K, E_Leak,
        F
        )

    return projection_neuron
end
