export projection_neuron_simulation

include("initial_condition.jl")
include("ODE.jl")

struct ProjectionNeuronSolution
    t::Vector{Float64}
    V::Vector{Float64}
    mNa::Vector{Float64}
    hNa::Vector{Float64}
    mdr::Vector{Float64}
    Ca_i::Vector{Float64}
end

function projection_neuron_simulation(u0, tspan, p)

    L = length(u0)
    if L != 5
        println("projection_neuron_simulation is not supposed to get a length(u0) = $L")
    end

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_projection_neuron, stochastic_system_projection_neuron, u0, tspan, p) 
    sol = solve(prob,dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #
    t      = sol.t
    V      = sol[1, :]
    mNa    = sol[2, :]
    hNa    = sol[3, :]
    mdr    = sol[4, :]
    Ca_i   = sol[5, :]

    projection_neuron_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,Ca_i)

    return projection_neuron_solution
end