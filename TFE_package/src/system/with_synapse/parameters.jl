export synapse_parameter

struct SynapseParameters
    g_NMDA::Float64
    g_AMPA::Float64
    E_NMDA::Float64
    E_AMPA::Float64

    w_AMPA::Float64
    tau_rise_AMPA::Float64
    tau_decay_AMPA::Float64
    tau_fac_AMPA::Float64
    tau_rec_AMPA::Float64
    U1_AMPA::Float64
    
    w_NMDA::Float64
    tau_rise_NMDA::Float64
    tau_decay_NMDA::Float64
    tau_fac_NMDA::Float64
    tau_rec_NMDA::Float64
    U1_NMDA::Float64

    ratio::Float64
    delay_AMPA::Float64
    delay_NMDA::Float64
end

function synapse_parameter(;

    g_NMDA = 2.0 * 1.0,           # [mS/cm²] # default = 1.0
    g_AMPA = 4.0 * 1.0,           # [mS/cm²] # default = 1.0
    E_NMDA = 0.0,         # [mV]
    E_AMPA = 0.0,         # [mV]

    delay_AMPA = 0.5,        # [mV]
    delay_NMDA = 0.5,        # [mV]

    w_AMPA          = 0.00225*8,
    tau_rise_AMPA   = 0.1,       # [ms]
    tau_decay_AMPA  = 5.0,       # [ms]
    tau_fac_AMPA    = 0.1,       # [ms]
    tau_rec_AMPA    = 0.1,       # [ms]
    U1_AMPA         = 1.0,

    w_NMDA          = 0.003*8,
    tau_rise_NMDA   = 2.0,       # [ms]
    tau_decay_NMDA  = 100.0,     # [ms]
    tau_fac_NMDA    = 0.1,       # [ms]
    tau_rec_NMDA    = 0.1,       # [ms]
    U1_NMDA         = 1.0,

    # ratio of the INMDA that is ICa
    ratio = 0.1,         # [.]
    )

    synapse = SynapseParameters(
        g_NMDA, g_AMPA,
        E_NMDA, E_AMPA,
        w_AMPA, tau_rise_AMPA, tau_decay_AMPA, tau_fac_AMPA, tau_rec_AMPA,U1_AMPA,
        w_NMDA, tau_rise_NMDA, tau_decay_NMDA, tau_fac_NMDA, tau_rec_NMDA,U1_NMDA,
        ratio, delay_AMPA, delay_NMDA
        )

    return synapse
end
