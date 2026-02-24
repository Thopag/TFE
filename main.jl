include("DIV0/params.jl")
include("DIV7/params.jl")

folder = "DIV0"

if folder == "DIV0"
    launch_simulation = ODE_DIV0.simulation
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    launch_simulation = ODE_DIV7.simulation
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function parameter_analyses()

    println("------ Start parameter analyses ------")
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = 1000.0          # ms
    u0 = get_u0()

    params = Vector{Parameters}()
    amps = 0:50:2500
    for amp in amps
        param = get_param(amp, stim_on, stim_length)
        push!(params, param)
    end

    p_volt = empty_voltage_plot()
    L = length(params)
    peaks_count = Vector{Int}()

    for ((i,param), amp) in zip(enumerate(params), amps)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), param)
        #plot!(p_volt, t, V, label=L"%$amp pA", alpha= 0.5)

        peaks_idx, n_peak = get_peaks(t, V;  min_h=-60, min_proms=5, max_w=15)
        push!(peaks_count, n_peak)
    end
    println("\n------ Plots ------")
    #display(p_volt)

    p_peaks = plot(amps, peaks_count, xlabel="--- (--)", ylabel= "Peaks count (-)")
    display(p_peaks)

    println("------ End parameter analyses ------")
end

function main()

    amp = 2000                    # pA
    duration = 1700.0             # ms
    stim_on = 500.0               # ms
    stim_length = 1000.0          # ms

    p = get_param(amp, stim_on, stim_length; 

        g_nav1p3 = 0.0,
        g_nav1p8 = 30.0,
        g_nav1p7 = 3.0,

        g_Leak = 0.025,

        g_AHP = 2.5,
        g_Km = 0.05,
        g_Kdr = 3.5,
        with_noise=false,
    )

    u0 = get_u0()

    print("folder: $folder with amp = $amp pA\n")

    print("--------------- Start Simulation ---------------\n")
    t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), p)
    print("--------------- End Simulation ---------------\n")

    I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, I_Leak = give_currents(V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP, p)
    peaks_idx, n_peak = get_peaks(t, V;  min_h=-60, min_proms=5, max_w=15)

    # --- Plots --- #

    p_volt = empty_voltage_plot()
    plot_voltage(t, V, amp, peaks_idx; given_p=p_volt, save=true, with_peak=true)

    # plot_variables(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)
    # plot_channels(t, V, m3, h3, m7, h7, m8, h8, ndr, ldr, nm, z_AHP, amp)
    # plot_currents(t, V, I_NaV1p3, I_NaV1p7, I_NaV1p8, I_Kdr, I_Km, I_AHP, amp)
    # plot_test(t, V, ndr, ldr, n_test, l_test, amp)
    # plot_availability_voltage(t, V, m7, h7, m8, h8)
end

#main()
parameter_analyses()