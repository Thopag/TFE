export model_parameter, stimulation_parameter, noise_parameter

# --------------- LIDOCAINE --------------- #

# In "lidocaine.jl"

# --------------- NOCICEPTOR --------------- #

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

# initiation in "init_nociceptor.jl"

# --------------- PROJECTION NEURON --------------- #

struct ProjectionNeuronParameters
    C::Float64
    p_Ca_L::Float64
    E_Na::Float64
    g_Na::Float64
    E_K::Float64
    g_KDR::Float64
    g_K_ir::Float64
    g_K_M::Float64
    E_Leak::Float64
    g_Leak::Float64
    nociceptor_input::Float64
end

function projection_neuron_parameter(;
    nociceptor_input = 5.0,
    # conductances
    g_Na::Float64 = 30.0,         # [mS/cm^2]
    g_KDR::Float64 = 4.0,         # [mS/cm^2]
    g_Leak::Float64 = 0.033,      # [mS/cm^2]

    # demander a annalelle
    p_Ca_L::Float64 = 0.0,
    g_K_ir::Float64 = 0.0,         # [mS/cm^2]
    g_K_M::Float64 = 0.0,          # [mS/cm^2]

    # Reversal Potential 
    E_Na::Float64 = 50.0,         # [mV]
    E_K::Float64 = -90.0,         # [mV]
    E_Leak::Float64 = -60.1       # [mV]
    )

    C = 1.0                                 # [µF/cm^2]

    projection_neuron = ProjectionNeuronParameters(
        C, p_Ca_L,
        E_Na, g_Na,
        E_K, g_KDR, g_K_ir, g_K_M,
        E_Leak, g_Leak,
        nociceptor_input
        )

    return projection_neuron
end

const DEFAULT_PROJ_NEURON = projection_neuron_parameter()

# --------------- STIMULATION --------------- #

struct StimulationParameters
    amp::Float64
    Ihold::Float64
    on::Float64
    off::Float64
end

function stimulation_parameter(amp;
    Ihold::Float64 = 0.0,              # [pA]     # Note: In original model, Ihold = -3.0 for DIV0 and 0.0 for DIV7
    on::Float64 = 500.0,               # [ms]
    length::Float64 = 1000.0           # [ms]
    )

    off = on + length

    stimulation = StimulationParameters(
        amp, Ihold,
        on, off
        )

    return stimulation
end

# --------------- NOISE --------------- #

struct NoiseParameters
    sigma::Float64
    mu::Float64
    tau::Float64
    with_noise::Bool
end

function noise_parameter(;
    with_noise::Bool = false,
    mu::Float64 = 0.0,
    tau::Float64 = 5.0,    # (ms)
    sigma::Float64 = 0.05
    )

    noise = NoiseParameters(
        sigma,
        mu,
        tau,
        with_noise,
        )

    return noise
end

const DEFAULT_NOISE = noise_parameter()

# --------------- MODEL PARAMETER --------------- #

struct ModelParameters
    lidocaine::LidocaineParameters
    stimulation::StimulationParameters
    nociceptor::NociceptorParameters
    projection_neuron::ProjectionNeuronParameters
    noise::NoiseParameters
end

function model_parameter(stimulation::StimulationParameters, nociceptor::NociceptorParameters
                    ;projection_neuron=DEFAULT_PROJ_NEURON, lidocaine::LidocaineParameters=DEFAULT_LIDOCAINE, noise::NoiseParameters=DEFAULT_NOISE)
    return ModelParameters(lidocaine, stimulation, nociceptor, projection_neuron, noise)
end
