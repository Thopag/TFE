export model_parameter, stimulation_parameter, noise_parameter

include("lidocaine.jl")
include("nociceptor/parameters.jl")
include("projection_neuron/parameters.jl")
include("with_synapse/parameters.jl")

# --------------- STIMULATION --------------- #

struct StimulationParameters{F}
    amp::Float64
    Ihold::Float64
    on::Float64
    off::Float64
    is_activated::F
end

function stimulation_parameter(amp;
    Ihold::Float64 = 0.0,              # [pA]     # Note: In original model, Ihold = -3.0 for DIV0 and 0.0 for DIV7
    on::Float64 = 500.0,               # [ms]
    length::Float64 = 1000.0           # [ms]
    )

    off = on + length
    is_activated(t) = pulse(t, on, off)

    stimulation = StimulationParameters(
        amp, Ihold,
        on, off,
        is_activated
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

# --------------- DATA SAVING --------------- #

struct SavedEvents
    n_t_spikes::Vector{Float64}
    n_V_spikes::Vector{Float64}
    pn_t_spikes::Vector{Float64}
    pn_V_spikes::Vector{Float64}
    t_NMDA_response::Vector{Float64}
    t_AMPA_response::Vector{Float64}
end

# --------------- MODEL PARAMETER --------------- #

struct ModelParameters{F}
    stimulation::StimulationParameters{F}
    nociceptor::NociceptorParameters
    projection_neuron::ProjectionNeuronParameters
    synapse::SynapseParameters
    lidocaine::LidocaineParameters
    noise::NoiseParameters
    save::SavedEvents
end

function model_parameter(stimulation::StimulationParameters, nociceptor::NociceptorParameters;
                    projection_neuron::ProjectionNeuronParameters   = DEFAULT_PROJ_NEURON, 
                    lidocaine::LidocaineParameters                  = DEFAULT_LIDOCAINE, 
                    synapse::SynapseParameters                      = DEFAULT_SYNAPSE,
                    noise::NoiseParameters                          = DEFAULT_NOISE)

    saved_events = SavedEvents(Float64[],Float64[],Float64[],Float64[],Float64[],Float64[])
        
    return ModelParameters(stimulation, nociceptor, projection_neuron, synapse, lidocaine, noise, saved_events)
end
