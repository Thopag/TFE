include("utils.jl")

function launch_from_file(file)

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r = load_file(file)

    # results = nothing to force the remake

    if !isnothing(fp)
        analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
    else
        println("No fp")
    end

    if !isnothing(pp)
        plan_r = launch_plan(pp, plan_r)
        save(file; pp=pp, plan_r=plan_r)
    else
        println("No pp")
    end  
end

function main()

    file = "DIV0_default"

    launch_from_file(file)
end

main()