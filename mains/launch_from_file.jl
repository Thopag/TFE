include("utils.jl")

function launch_from_file(file)

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    # results = nothing to force the remake

    if !isnothing(fp)
        analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
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

    files = [
            # "plan/DIV0_NMDA_inhib_m8_shift",
            "plan/DIV0_shift_Mgblock_inhib_NMDA",
            "plan/DIV0_NMDA_inhib_h8_shift",
            ]

    for file in files
        println("-------------------------------------")
        println()
        println("FILE IS $file")
        println()
        println("-------------------------------------")
        launch_from_file(file)
    end

    #launch_from_file("shift/DIV7_h3_shift")

end

main()