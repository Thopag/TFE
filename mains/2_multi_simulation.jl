
############################ PARAMETER SET TYPE ############################
folder = "DIV7"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function main()

    amps = 35.0:5:50.0

    # -------- Set up -------- #

    changing_params = amps
    changing_param_name = "amp (pA)"
    u0 = get_u0()

    # -------- Timing set up -------- #

    duration = 1700.0               # ms
    stim_on = 500.0                 # ms
    stim_length = 1000.0            # ms

    # -------- Plot Set up -------- #

    xlimits = (400, 1700)

    V_limits = (-80, 40)
    plt_V = plot(ylabel="Voltage (mV)", xlabel="time (ms)", legend=:topright,
                xlimits=xlimits, ylimits=V_limits)

    L = length(changing_params)
    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("")
    println("Bifurcation parameter is [$changing_param_name]")
    println("   with values : $changing_params")

    for (i,changing_param) in enumerate(changing_params)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        p = get_param(changing_param; stim_on=stim_on, stim_length=stim_length)
        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), p)

        plot!(plt_V, t, V, label="$changing_param")
    end
    println("\r################ End Looping ################ ")

    #display(plt_V)
    savefig(plt_V, "plots/multi_simulation/voltage.pdf")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end