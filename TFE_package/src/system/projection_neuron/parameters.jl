export projection_neuron_parameter

struct ProjectionNeuronParameters
    C::Float64
    d::Float64
    CellArea::Float64
    Ca_i0::Float64
    tau_Ca::Float64
    k::Float64
    g_Na::Float64
    g_K_dr::Float64
    g_Leak::Float64
    E_Na::Float64
    E_K::Float64
    E_Leak::Float64
    F::Float64
end

function projection_neuron_parameter(;

    # conductances
    g_Na = 30.0,         # [mS/cm^2]
    g_K_dr = 4.0,        # [mS/cm^2]
    g_Leak = 0.03268,    # [mS/cm^2]

    # Ca
    k = 1.0e4,                      # [µm.cm^(-1)] 
    Ca_i0 = 5.0e-5,                 # [mM]
    tau_Ca = 2.0,                    # [ms]

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
        Ca_i0, tau_Ca, k,
        g_Na, g_K_dr, g_Leak,
        E_Na, E_K, E_Leak,
        F
        )

    return projection_neuron
end
