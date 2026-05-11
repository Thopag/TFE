using BifurcationKit, Accessors

############################ PARAMETER SET TYPE ############################
folder = "DIV0"
############################ PARAMETER SET TYPE ############################

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function make_bifurcation(param_init, u0, lens_param, p_min, p_max)

    prob = BifurcationProblem(ODE.ODE_system_bifurcation, u0, param_init, lens_param, 
        record_from_solution = (x, p; k...) -> x[1])

    step_scaling = 100
    opts = ContinuationPar(
        p_min = 0.0, 
        p_max = 300.0,
        max_steps = 10000*step_scaling ,
        dsmin = 0.01/step_scaling , 
        ds = 0.1/step_scaling ,
        dsmax = 1/step_scaling ,
        detect_bifurcation = 3,
    )
    br = continuation(prob, PALC(), opts)

    return br
end

function main()

    # ---- bifurcation set up ---- #

    u0 = get_u0()[1:end-1]

    p_min = 0.0
    p_max = 300.0

    starting_param = p_min
    lens_param = PropertyLens(:amp)

    # ---- inter bifurcation parameter ---- #

    C_lido = [0.0, 100.0, 1000.0]
    shifts = 0:1:15.0
    inhibs = [0.0, 0.3, 0.5, 0.7, 0.9, 0.925, 0.95, 0.975, 1.0]
    inter_params = shifts
    L = length(inter_params)

    file_prefix = "$(folder)_1.8_40_60_shifts_"

    # ---- Plot set up ---- #

    color_specialpoint = Dict{Symbol, Symbol}(:hopf => :red, :bp => :green, :endpoint => :black)

    param_label = "amp (pA)"
    plt = plot(xlabel=param_label, ylabel=" Voltage (mV)", legendfontsize=7)

    for (symbol_type, color) in color_specialpoint
        scatter!(plt, [], [], label="$(symbol_type)", c=color)
    end

    reds, blues, greens, greys = sodium_palettes(L; dark=0.8, light=0.5)

    println(shift_setup())
    for (i,inter_parameter) in enumerate(inter_params)
        changing_label = "$(inter_parameter)"
        plot!(plt, [], [], label=changing_label, color=greys[i], alpha=1)

        println("Inter value : $inter_parameter -- $(round(((i-1)/L*100), digits=2)) % is done")

        # ---- Make bifurcations ---- #
        param_init = get_param(starting_param;
        #"""###################### PARAMETER ######################"""#   
                    C_lidocaine=inter_parameter,
                    )
        #"""#######################################################"""#

        br = make_bifurcation(param_init, u0, lens_param, p_min, p_max)
        #print(show(br))

        # ----  Plot result ---- #
        V = br.branch.x
        bif_param = br.branch.param
        stability = br.branch.stable

        #color_stability = [:red, :blue]
        color_stability = [reds[i], blues[i]]
        plot!(plt, bif_param , V, c=color_stability[stability .+ 1], label="", linewidth = 1.5)

        # Add special point
        for specialpoint in br.specialpoint
            idx = specialpoint.idx
            symbol_type = specialpoint.type
            color = get(color_specialpoint, symbol_type, :blue)
            scatter!(plt, [bif_param[idx]], [V[idx]], label="", c=color)
        end
    end

    # ----  End Plots ---- #

    #display(plt)
    savefig(plt, "plots/bifurcation/$(file_prefix)bifurcation.pdf")
    savefig(plt, "plots/bifurcation/$(file_prefix)bifurcation.png")

end

main()