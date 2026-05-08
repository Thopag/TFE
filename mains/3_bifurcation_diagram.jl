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

function main()

    # ---- Plot set up ---- #

    color_stability = [:red, :blue]
    color_specialpoint = Dict{Symbol, Symbol}(:hopf => :red, :bp => :green, :endpoint => :black)

    param_label = "amp (pA)"
    plt = plot(xlabel=param_label, ylabel=" Voltage (mV)")

    # ---- bifurcation set up ---- #

    u0 = get_u0()[1:end-1]

    starting_param = 0.0
    param_init = get_param(starting_param)

    lens_param = PropertyLens(:amp)

    # ---- Make bifurcation ---- #

    prob = BifurcationProblem(ODE.ODE_system_bifurcation, u0, param_init, lens_param, 
            record_from_solution = (x, p; k...) -> x[1])

    opts = ContinuationPar(
        p_min = 0.0, 
        p_max = 300.0,
        max_steps = 10000,
        dsmax = 0.1, 
        detect_bifurcation = 3,
    )
    br = continuation(prob, PALC(), opts)

    # ----  Plot result ---- #

    V = br.branch.x
    bif_param = br.branch.param
    stability = br.branch.stable
    
    plot!(plt, bif_param , V, c=color_stability[stability .+ 1], label="", linewidth = 1.5)

    # Add special point
    for specialpoint in br.specialpoint
        idx = specialpoint.idx
        symbol_type = specialpoint.type
        color = get(color_specialpoint, symbol_type, :blue)
        scatter!(plt, [bif_param[idx]], [V[idx]], label="$(symbol_type)", c=color)
    end

    # ----  End Plots ---- #

    #display(plot(br))
    #display(plt)
    #show(br)

    savefig(plt, "plots/bifurcation/bifurcation_$(folder).pdf")

end

main()