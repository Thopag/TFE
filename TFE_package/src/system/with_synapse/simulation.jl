export with_synapse_simulation

include("initial_condition.jl")
include("simulation_events.jl")
include("ODE.jl")

struct SynapseSolution
    t::Vector{Float64}
    V::Vector{Float64}
    A_NMDA::Vector{Float64}
    B_NMDA::Vector{Float64}
    Use_NMDA::Vector{Float64}
    P_NMDA::Vector{Float64}
    A_AMPA::Vector{Float64}
    B_AMPA::Vector{Float64}
    Use_AMPA::Vector{Float64}
    P_AMPA::Vector{Float64}
    t_NMDA_response::Vector{Float64}
    t_AMPA_response::Vector{Float64}
end

# doc solve : https://docs.sciml.ai/DiffEqDocs/stable/basics/common_solver_opts/

function with_synapse_simulation(u0, tspan, p)

    idx = p.idx
    L = length(u0)
    if L != idx.s[end]
        println("with_synapse_simulation is not supposed to get a length(u0) = $L")
    end

    # -- callbacks set up -- #
    cbs = CallbackSet(  cb_n_spike,
                        cb_pn_spike,
                        cb_NMDA_spike_response,
                        cb_AMPA_spike_response
                    )

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_with_synapse, stochastic_system_with_synapse, u0, tspan, p) 
    sol = solve(prob, callback=cbs, dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #

    t      = sol.t

    # -- Nociceptor -- #
    V      = sol[idx.n[1], :]
    m3     = sol[idx.n[2], :]
    h3     = sol[idx.n[3], :]
    m7     = sol[idx.n[4], :]
    h7     = sol[idx.n[5], :]
    m8     = sol[idx.n[6], :]
    h8     = sol[idx.n[7], :]
    ndr    = sol[idx.n[8], :]
    ldr    = sol[idx.n[9], :]
    nM     = sol[idx.n[10], :]
    zAHP   = sol[idx.n[11], :]

    Inoise = sol[idx.noise, :]

    nociceptor_solution = NociceptorSolution(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nM,zAHP,Inoise,
                                                                p.save.n_t_spikes, p.save.n_V_spikes)

    # -- Projection Neuron -- #
    V      = sol[idx.pn[1], :]
    mNa    = sol[idx.pn[2], :]
    hNa    = sol[idx.pn[3], :]
    mdr    = sol[idx.pn[4], :]
    mir  = sol[idx.pn[5], :]
    mM   = sol[idx.pn[6], :]

    mLs  = sol[idx.pn[7], :]
    hLs  = sol[idx.pn[8], :]
    mLf  = sol[idx.pn[9], :]
    hLf  = sol[idx.pn[10], :]
    Ca_i    = sol[idx.pn[11], :]

    projection_neuron_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,mir,mM,mLs,hLs,mLf,hLf,Ca_i,
                                                            p.save.pn_t_spikes, p.save.pn_V_spikes)

    # -- Synapse -- #
    A_NMDA      = sol[idx.s[1], :]
    B_NMDA      = sol[idx.s[2], :]
    Use_NMDA    = sol[idx.s[3], :]
    P_NMDA      = sol[idx.s[4], :]
    A_AMPA      = sol[idx.s[5], :]
    B_AMPA      = sol[idx.s[6], :]
    Use_AMPA    = sol[idx.s[7], :]
    P_AMPA      = sol[idx.s[8], :]

    synapse_solution = SynapseSolution(t,V,A_NMDA,B_NMDA,Use_NMDA,P_NMDA,A_AMPA,B_AMPA,Use_AMPA,P_AMPA,
                                                            p.save.t_NMDA_response, p.save.t_AMPA_response)

    return nociceptor_solution, projection_neuron_solution, synapse_solution
end