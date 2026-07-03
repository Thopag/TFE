export projection_neuron_parameter

struct ProjectionNeuronParameters
    C::Float64
    d::Float64
    CellArea::Float64
    Ca_i_0::Float64
    Ca_o::Float64
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
    g_Na = 50.0,            # [mS/cm^2]
    g_K_dr = 10.0,          # [mS/cm^2]
    g_K_ir = 0.03,          # [mS/cm^2]
    g_K_M = 0.015,          # [mS/cm^2]
    g_Leak = 0.03268,       # [mS/cm^2]

    # Ca
    pLf = 1.5e-5,       # [cm*s^-1]
    pLs = 1.3e-5,       # [cm*s^-1]

    k = 1.0e7,          # [nm.cm^(-1)]
    Ca_i_0 = 5.0e-5,    # [mM]
    Ca_o = 2.0,         # [mM]
    tau_Ca = 10.0,      # [ms]

    # Reversal Potential 
    E_Na = 50.0,         # [mV]
    E_K = -90.0,         # [mV]
    E_Leak = -60.1,       # [mV]

    C = 1.0,                # [µF/cm^2]
    d = 1.0,                # [nm]
    )

    L = 20                 # [µm]
    D = 20                 # [µm]
    CellArea = 2.0*pi*(D/2)*L

    F = 96520.0            # [C/mol]

    projection_neuron = ProjectionNeuronParameters(
        C, d, CellArea,
        Ca_i_0, Ca_o, tau_Ca, k,
        g_Na, g_K_dr, g_K_ir, g_K_M, g_Leak,
        pLf, pLs,
        E_Na, E_K, E_Leak,
        F
        )

    return projection_neuron
end
