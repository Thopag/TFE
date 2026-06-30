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

    idx = p.idx
    L = length(u0)
    if L < (length(idx.n))
        println("(nociceptor_simulation) Size of u0 can not match : $L")
    end

    if L >= (length(idx.n))
        u0 = u0[idx.n]

        # add an element for noise
        push!(u0, 0.0)
    end

    # -- callbacks set up -- #
    cbs = CallbackSet(cb_n_spike)

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_nociceptor, stochastic_system_nociceptor, u0, tspan, p) 
    sol = solve(prob, callback=cbs, dtmax=0.01, maxiters=1e7)

    # -- Simulation results -- #
    t      = sol.t
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

    return nociceptor_solution , nothing, nothing
end