export projection_neuron_simulation

include("initial_condition.jl")
include("simulation_events.jl")
include("ODE.jl")

struct ProjectionNeuronSolution
    t::Vector{Float64}
    V::Vector{Float64}
    mNa::Vector{Float64}
    hNa::Vector{Float64}
    mdr::Vector{Float64}
    Ca_i::Vector{Float64}
    t_spikes::Vector{Float64}
    V_spikes::Vector{Float64}
end

function projection_neuron_simulation(u0, tspan, p)

    idx = p.idx
    L = length(u0)
    if L < (length(idx.pn))
        println("(projection_neuron_simulation) Size of u0 can not match : $L")
    end

    # -- callbacks set up -- #
    cbs = CallbackSet(cb_pn_spike)

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_projection_neuron, stochastic_system_projection_neuron, u0, tspan, p) 
    sol = solve(prob, callback=cbs, dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #
    t      = sol.t
    V      = sol[idx.pn[1], :]
    mNa    = sol[idx.pn[2], :]
    hNa    = sol[idx.pn[3], :]
    mdr    = sol[idx.pn[4], :]
    Ca_i   = sol[idx.pn[5], :]

    projection_neuron_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,Ca_i,
                                                            p.save.pn_t_spikes, p.save.pn_V_spikes)

    return projection_neuron_solution
end