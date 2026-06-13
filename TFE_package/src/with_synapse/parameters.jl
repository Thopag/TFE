export synapse_parameter

struct SynapseParameters
    g_NMDA::Float64
    g_AMPA::Float64
    E_NMDA::Float64
    E_AMPA::Float64

    tau_rise_AMPA::Float64
    tau_decay_AMPA::Float64
    tau_fac_AMPA::Float64
    tau_rec_AMPA::Float64

    tau_rise_NMDA::Float64
    tau_decay_NMDA::Float64
    tau_fac_NMDA::Float64
    tau_rec_NMDA::Float64

    ratio::Float64
end

function synapse_parameter(;

    g_NMDA = 1.0,         # [mS/cm²]
    g_AMPA = 1.0,         # [mS/cm²]
    E_NMDA = 0.0,         # [mV]
    E_AMPA = 0.0,         # [mV]

    tau_rise_AMPA   = 0.1,       # [ms]
    tau_decay_AMPA  = 5.0,       # [ms]
    tau_fac_AMPA    = 0.1,       # [ms]
    tau_rec_AMPA    = 0.1,       # [ms]

    tau_rise_NMDA   = 2.0,       # [ms]
    tau_decay_NMDA  = 100.0,     # [ms]
    tau_fac_NMDA    = 0.1,       # [ms]
    tau_rec_NMDA    = 0.1,       # [ms]

    # ratio of the INMDA that is ICa
    ratio = 0.1,         # [.]
    )

    synapse = SynapseParameters(
        g_NMDA, g_AMPA,
        E_NMDA, E_AMPA,
        tau_rise_AMPA, tau_decay_AMPA, tau_fac_AMPA, tau_rec_AMPA,
        tau_rise_NMDA, tau_decay_NMDA, tau_fac_NMDA, tau_rec_NMDA,
        ratio
        )

    return synapse
end

const DEFAULT_SYNAPSE = synapse_parameter()
