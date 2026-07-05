include("utils.jl")

function main()

    files = ["DIV0_inhib_NMDA", "DIV0_inhib_NaV1.8", "DIV0_inhib_AMPA", "DIV0_plan_inhib_NaV1.8_NMDA"]

    #file = "DIV0_default"
    file = files[4]

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)
    println(typeof(plan_exct))
    println(typeof(plan_freq))

    plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file)
    plot_plan(pp, plan_exct, plan_freq, file)
end

main()