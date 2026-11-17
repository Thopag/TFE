include("utils.jl")

function main()

    file = "data/DIV0_Nav1p8_2D"
    start = 5
    file = file[start:end]

    f_1D, f_2D, r_1D, r_2D_I, r_2D_freq = load_file(file)

    show_analyses(f_1D, r_1D, file)

    show_current_plan(f_2D, r_2D_I, file)
    show_frequency_plan(f_2D, r_2D_freq, file)
end

main()