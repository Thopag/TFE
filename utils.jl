using DifferentialEquations
include("ODEs.jl")

## Functions useful for defining variations in the external current 
function heaviside(t)
     ###############################################################
        ########## This function defines a heaviside  ############

        # --> returns 1 if t>=0 and 0 otherwise
        ## Arguments 
        # t : time variable
    ###############################################################
    return 0*(t<0) + 1*(t>=0)
end

function pulse(t,ti,tf)
     ###############################################################
        ############# This function defines a pulse  ###############

        # --> returns 1 if ti <= t < tf and 0 otherwise
        ## Arguments 
        # t : time variable
        # ti : time at which the pulse starts
        # tf : time at which the pulse ends
    ###############################################################
    return heaviside(t-ti)-heaviside(t-tf)
end

function simulation(u0, tspan, p)

    # -- SDE Simulation -- #
    prob = SDEProblem(ODE_system, stochastic_part, u0, tspan, p) 
    sol = solve(prob,dtmax=0.1);

    # -- Simulation results -- #
    t = sol.t
    V      = sol[1, :]
    m3     = sol[2, :]
    h3     = sol[3, :]
    m7     = sol[4, :]
    h7     = sol[5, :]
    m8     = sol[6, :]
    h8     = sol[7, :]
    ndr    = sol[8, :]
    ldr    = sol[9, :]
    nm     = sol[10, :]
    z_AHP  = sol[11, :]
    Inoise = sol[12, :]

    return t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise
end

function give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)

    g_nav1p3 = p[3]
    g_nav1p7 = p[4]
    g_nav1p8 = p[5]
    E_Na = p[6]

    g_Kdr = p[7]
    g_Km = p[8]
    g_AHP = p[9]
    E_k = p[10]

    g_Leak = p[11]
    E_Leak = p[12]

    INaV1p3 = g_nav1p3 .* (m3.^3) .* h3 .* (V .- E_Na)
    INaV1p7 = g_nav1p7 .* (m7.^3) .* h7 .* (V .- E_Na)
    INaV1p8 = g_nav1p8 .* (m8.^3) .* h8 .* (V .- E_Na)
    IKdr = g_Kdr .* (ndr.^3) .* ldr .* (V .- E_k)
    IKm = g_Km .* nm .* (V .- E_k)
    IAHP = g_AHP .* (z_AHP.^1) .* (V .- E_k)
    ILeak = g_Leak .* (V .- E_Leak)

    return INaV1p3, INaV1p7, INaV1p8, IKdr, IKm, IAHP, ILeak
    
end