include("utils.jl")

function launch_from_file(file)

    fp, pp, analyse_r, bifurcation_r, plan_exct, plan_freq = load_file(file)

    # results = nothing to force the remake

    if !isnothing(fp)
        analyse_r, bifurcation_r = launch_analyses(fp, analyse_r, bifurcation_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r)
    else
        println("No fp")
    end

    if !isnothing(pp)
        plan_exct, plan_freq = launch_plan(pp, plan_exct, plan_freq)
        save(file; pp=pp, plan_exct=plan_exct, plan_freq=plan_freq)
    else
        println("No pp")
    end
end

function main()

    files = ["paper/DIV0_NaV1p8_modulation_space",
            "paper/DIV7_NaV1p7_modulation_space",
            "paper/DIV0_m8_shift",
            "paper/DIV0_h8_shift",
            "paper/DIV0_NaV1p8_inhib",
            "paper/DIV7_h7_shift",
            "paper/DIV7_NaV1p7_inhib",
            ]

    for file in files
        println("-------------------------------------")
        println()
        println("FILE IS $file")
        println()
        println("-------------------------------------")
        launch_from_file(file)
    end

    #launch_from_file("")

end

main()