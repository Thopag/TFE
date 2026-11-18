include("utils.jl")

function launch_from_file(file)

    f_1D, f_2D, r_1D, r_2D_I, r_2D_freq = load_file(file)

    if print_analyses_setup(f_1D)
        if isnothing(r_1D)
            r_1D = launch_analyses(f_1D, r_1D)
            save(file; r_1D=r_1D)
        else
            println("analyses already done")
        end
    end

    if print_plan_setup(f_2D)

        if isnothing(r_2D_I)
            r_2D_I = launch_current_plan(f_2D, r_2D_I)
            save(file; r_2D_I=r_2D_I)
        else
            println("current_plan already done")
        end

        if isnothing(r_2D_freq)
            r_2D_freq = launch_frequency_plan(f_2D, r_2D_freq)
            save(file; r_2D_freq=r_2D_freq)
        else
            println("frequency_plan already done")
        end
    end
end

function main()

    files = [
            # "data/DIV0_Nav1p8_2D",
            # "data/DIV7_Nav1p7_2D",
            "data/DIV0",
            "data/DIV7",
            "data/PrjN"
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