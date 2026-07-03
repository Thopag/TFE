include("utils.jl")

function main()

    file = "DIV0_default"

    fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r = load_file(file)

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    plot_plan(plan_r, file)
end

main()