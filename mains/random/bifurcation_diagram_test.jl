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

    u0 = get_u0()
    u0 = u0[1:end-1]
    param_init = get_param(0.0)

    lens_amp = PropertyLens(:amp) 
    prob = BifurcationProblem(ODE.ODE_system_bifurcation, u0, param_init, lens_amp)

    opts = ContinuationPar(
        p_min = 0.0, 
        p_max = 300.0,
        max_steps = 10000,
        dsmax = 0.1, 
        detect_bifurcation = 3,
    )

    br = continuation(prob, PALC(), opts)

    plot(br)
end

main()