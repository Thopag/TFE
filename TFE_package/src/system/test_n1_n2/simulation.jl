export test_n1_n2_simulation,test_n1_n2_stimulation_parameter

include("initial_condition.jl")
include("ODE.jl")


function test_n1_n2_stimulation_parameter(;duration=15000.0, T=2000.0, scenario = "BT")

    Ihold = 0.0
    on = 0.0
    off = 0.0

    ti1=200.0
    tf1=350.0
    n_pulse = Int(ceil((duration/T)))
    if scenario == "BT"
        mul_pulse_BT(t,n)=sum(pulse(t,ti1+(i-1)*T,tf1+(i-1)*T) for i=1:n) #burst-like stimulation 
        is_activated_BT(t) = mul_pulse_BT(t,n_pulse)
        amp = 10.0
        stimulation = StimulationParameters(amp, Ihold,on, off,is_activated_BT)
        println("Burst-like stimulation ")
    elseif scenario == "SS"        
        mul_pulse_SS(t,n)=sum(pulse(t,ti1+(i-1)*T,ti1+25+(i-1)*T) for i=1:n) #single-spike-like stimulation
        is_activated_SS(t) = mul_pulse_SS(t,n_pulse)
        amp = 5.0
        println("Single-spike-like stimulation ")
        stimulation = StimulationParameters(amp, Ihold,on, off,is_activated_SS)
    else
        stimulation = stimulation_parameter(0.0)
    end

    stop_pulse(n) = [ti1+(i-1)*T for i=1:n]
    return stimulation, stop_pulse(n_pulse)
end

function test_n1_n2_simulation(u0, tspan, p, tstops)

    L = length(u0)
    if L != 25
        println("with_synapse_simulation is not supposed to get a length(u0) = $L")
    end

    # -- callbacks set up -- #
    cbs = CallbackSet(  cb_n_spike,
                        cb_syn_pn_spike,
                        cb_NMDA_spike_response,
                        cb_AMPA_spike_response
                    )

    # -- Simulation -- #
    prob = SDEProblem(ODE_system_test_n1_n2, stochastic_system_with_synapse, u0, tspan, p) 
    sol = solve(prob, callback=cbs, tstops=tstops, maxiters=1e7)

    # -- Simulation results -- #

    t      = sol.t

    # -- n1 -- #
    V      = sol[1, :]
    mNa     = sol[2, :]
    hNa     = sol[3, :]
    mdr     = sol[4, :]
    Ca_i     = sol[5, :]
    # m8     = sol[6, :]
    # h8     = sol[7, :]
    # ndr    = sol[8, :]
    # ldr    = sol[9, :]
    # nM     = sol[10, :]
    # zAHP  = sol[11, :]
    # Inoise = sol[end, :]

    nociceptor_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,Ca_i,
                                                            p.save.n_t_spikes, p.save.n_V_spikes)

    # -- n2 -- #
    V      = sol[12, :]
    mNa    = sol[13, :]
    hNa    = sol[14, :]
    mdr    = sol[15, :]
    Ca_i   = sol[16, :]

    projection_neuron_solution = ProjectionNeuronSolution(t,V,mNa,hNa,mdr,Ca_i,
                                                            p.save.pn_t_spikes, p.save.pn_V_spikes)

    # -- Synapse -- #
    A_NMDA      = sol[17, :]
    B_NMDA      = sol[18, :]
    Use_NMDA    = sol[19, :]
    P_NMDA      = sol[20, :]
    A_AMPA      = sol[21, :]
    B_AMPA      = sol[22, :]
    Use_AMPA    = sol[23, :]
    P_AMPA      = sol[24, :]

    synapse_solution = SynapseSolution(t,V,A_NMDA,B_NMDA,Use_NMDA,P_NMDA,A_AMPA,B_AMPA,Use_AMPA,P_AMPA,
                                                            p.save.t_NMDA_response, p.save.t_AMPA_response)

    return nociceptor_solution, projection_neuron_solution, synapse_solution
end