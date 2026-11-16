include("utils.jl")

function main()

    # inhib
    # start = 11

    # shift
    # start = 6

    # plan
    # start = 5

    file = "paper/DIV0_NaV1p8_inhib"
    start = 6

    fp, pp, analyse_r, bifurcation_r, plan_exct, plan_freq = load_file(file)

    file = file[start:end]

    plot_analyses(fp, analyse_r, bifurcation_r, file)
    plot_plan(pp, plan_exct, plan_freq, file)
end


main()