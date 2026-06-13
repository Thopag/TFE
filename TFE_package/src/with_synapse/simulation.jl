export with_synapse_simulation

include("initial_condition.jl")
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
end

function with_synapse_simulation(u0, tspan, p)

    L = length(u0)
    if L != 25
        println("with_synapse_simulation is not supposed to get a length(u0) = $L")
    end

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_with_synapse, stochastic_system_with_synapse, u0, tspan, p) 
    sol = solve(prob,dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #

    t      = sol.t

    # -- Nociceptor -- #
    V      = sol[1, :]
    m3     = sol[2, :]
    h3     = sol[3, :]
    m7     = sol[4, :]
    h7     = sol[5, :]
    m8     = sol[6, :]
    h8     = sol[7, :]
    ndr    = sol[8, :]
    ldr    = sol[9, :]
    nM     = sol[10, :]
    zAHP  = sol[11, :]
    Inoise = sol[end, :]

    nociceptor_solution = NociceptorSolution(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nM,zAHP,Inoise)

    # -- Projection Neuron -- #
    V      = sol[12, :]
    mNa    = sol[13, :]
    hNa    = sol[14, :]
    mdr    = sol[15, :]
    Ca_i   = sol[16, :]

    projection_neuron_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,Ca_i)

    # -- Synapse -- #
    A_NMDA      = sol[17, :]
    B_NMDA      = sol[18, :]
    Use_NMDA    = sol[19, :]
    P_NMDA      = sol[20, :]
    A_AMPA      = sol[21, :]
    B_AMPA      = sol[22, :]
    Use_AMPA    = sol[23, :]
    P_AMPA      = sol[24, :]

    synapse_solution = SynapseSolution(t,V,A_NMDA,B_NMDA,Use_NMDA,P_NMDA,A_AMPA,B_AMPA,Use_AMPA,P_AMPA)

    return nociceptor_solution, projection_neuron_solution, synapse_solution
end