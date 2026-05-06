
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

function record_min_max(record_on, record_off, t, x; tol=1.0)

    REC_x = x[record_on .< t .< record_off]

    max = maximum(REC_x)
    min = minimum(REC_x)
    is_stable = true

    if (max - min) <= tol
        mean = (max-min)/2
        return max, min, is_stable
    end

    is_stable = false
    return max, min, is_stable
end

function main()

    amps = 0.0:1:300.0

    # -------- Set up -------- #

    bifurcation_params = amps
    bifurcation_axe_label = "amp (pA)"
    u0 = get_u0()

    # -------- Timing set up -------- #

    duration = 2500.0               # ms
    stim_on = 500.0                 # ms
    stim_off = duration - 200
    stim_length = stim_off - stim_on

    # Time at which the max and min detection starts
    record_on = stim_off - 400          # ms
    record_off = stim_off               # ms

    # -------- Plot Set up -------- #

    plt_bif = plot(ylabel="Voltage (mV)", xlabel=bifurcation_axe_label, legend=:bottomright)

    L = length(bifurcation_params)

    println("################ Start Looping ################ ")
    println("Parameter set type : $folder")
    println("Duration : $duration ms")
    println("Recording from $record_on to $record_off ms")
    println("")
    println("Bifurcation parameter is [$bifurcation_axe_label]")
    println("   with values : $bifurcation_params")

    for (i,bifu_param) in enumerate(bifurcation_params)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        p = get_param(bifu_param; stim_on=stim_on, stim_length=stim_length)
        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,I_noise = simulation(u0, (0.0, duration), p)

        max, min, is_stable = record_min_max(record_on, record_off, t, V)

        if is_stable
            scatter!(plt_bif, [bifu_param, bifu_param], [max, min], label="", color=:blue)
        else
            scatter!(plt_bif, [bifu_param, bifu_param], [max, min], label="", color=:red)
        end
    end
    println("\r################ End Looping ################ ")

    #display(plt_bif)
    savefig(plt_bif, "plots/bifurcation/bifurcation.svg")
end

main()