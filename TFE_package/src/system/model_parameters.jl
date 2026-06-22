export stimulation_parameter, change_stimulation_amp, noise_parameter, model_parameter, from_model_parameter

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

function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

function stimulation_parameter(amp::Float64;
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

function change_stimulation_amp(amp::Float64, stim::StimulationParameters)
    return StimulationParameters(amp, stim.Ihold, stim.on, stim.off, stim.is_activated)
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
        sigma, mu, tau,
        with_noise,
        )
    return noise
end

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

function model_parameter(; 
                    stimulation::Union{Nothing,StimulationParameters}              = nothing,
                    nociceptor::Union{Nothing,NociceptorParameters}                = nothing,
                    projection_neuron::Union{Nothing,ProjectionNeuronParameters}   = nothing, 
                    synapse::Union{Nothing,SynapseParameters}                      = nothing,
                    lidocaine::Union{Nothing,LidocaineParameters}                  = nothing,
                    noise::Union{Nothing,NoiseParameters}                          = nothing)

    # someting -> return the first none "nothing" argument
    stim        = something(stimulation         , stimulation_parameter(0.0))
    n           = something(nociceptor          , DIV0_parameter())
    pn          = something(projection_neuron   , projection_neuron_parameter())
    s           = something(synapse             , synapse_parameter())
    lido        = something(lidocaine           , lidocaine_parameter())
    new_noise   = something(noise               , noise_parameter())

    saved_events = SavedEvents(Float64[],Float64[],Float64[],Float64[],Float64[],Float64[])
        
    return ModelParameters(stim, n, pn, s, lido, new_noise, saved_events)
end

function from_model_parameter(p_model::ModelParameters; 
                    stimulation::Union{Nothing,StimulationParameters}              = nothing,
                    nociceptor::Union{Nothing,NociceptorParameters}                = nothing,
                    projection_neuron::Union{Nothing,ProjectionNeuronParameters}   = nothing, 
                    synapse::Union{Nothing,SynapseParameters}                      = nothing,
                    lidocaine::Union{Nothing,LidocaineParameters}                  = nothing,
                    noise::Union{Nothing,NoiseParameters}                          = nothing)

    # someting -> return the first none "nothing" argument
    stim        = something(stimulation         , p_model.stimulation)
    n           = something(nociceptor          , p_model.nociceptor)
    pn          = something(projection_neuron   , p_model.projection_neuron)
    s           = something(synapse             , p_model.synapse)
    lido        = something(lidocaine           , p_model.lidocaine)
    new_noise   = something(noise               , p_model.noise)

    saved_events = SavedEvents(Float64[],Float64[],Float64[],Float64[],Float64[],Float64[])
        
    return ModelParameters(stim, n, pn, s, lido, new_noise, saved_events)
end
