export nociceptor_simulation

include("initial_condition.jl")
include("simulation_events.jl")
include("ODE.jl")

struct NociceptorSolution
    t::Vector{Float64}
    V::Vector{Float64}
    m3::Vector{Float64}
    h3::Vector{Float64}
    m7::Vector{Float64}
    h7::Vector{Float64}
    m8::Vector{Float64}
    h8::Vector{Float64}
    ndr::Vector{Float64}
    ldr::Vector{Float64}
    nM::Vector{Float64}
    zAHP::Vector{Float64}
    Inoise::Vector{Float64}
    t_spikes::Vector{Float64}
    V_spikes::Vector{Float64}
end

function nociceptor_simulation(u0, tspan, p)

    L = length(u0)
    if L == 25
        u0 = u0[1:11]
    end

    L = length(u0)
    if (L > 12) || (L < 11)
        println("nociceptor_simulation is not supposed to get a length(u0) = $L")
    end

    # add an element for noise if needed
    if L == 11
        push!(u0, 0.0)
    end

    # -- callbacks set up -- #
    cbs = CallbackSet(cb_n_spike)

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_nociceptor, stochastic_system_nociceptor, u0, tspan, p) 
    sol = solve(prob, callback=cbs, dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #
    t      = sol.t
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

    nociceptor_solution = NociceptorSolution(t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nM,zAHP,Inoise,
                                                    p.save.n_t_spikes, p.save.n_V_spikes)

    return nociceptor_solution
end