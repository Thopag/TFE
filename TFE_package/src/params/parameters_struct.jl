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

# --------------- STIMULATION --------------- #

struct StimulationParameters
    amp::Float64
    Ihold::Float64
    on::Float64
    off::Float64
end

function stimulation_parameter(amp;
    Ihold = 0.0,              # [pA]     # Note: In original model, Ihold = -3.0 for DIV0 and 0.0 for DIV7
    on = 500.0,               # [ms]
    length = 1000.0           # [ms]
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
    with_noise = false,
    mu = 0.0,
    tau = 5.0,    # (ms)
    sigma = 0.05
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
    noise::NoiseParameters
end

function model_parameter(stimulation, nociceptor; lidocaine=DEFAULT_LIDOCAINE, noise=DEFAULT_NOISE)
    return ModelParameters(lidocaine, stimulation, nociceptor, noise)
end
