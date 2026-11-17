using JLD2

function load_file(file)

    println("Loading : $(file)")

    f_1D = nothing
    filepath = "JLD2_save/$(file)_1D_parameters.jld2"
    if isfile(filepath)
        println("Get 1D_parameters")
        jldopen(filepath, "r") do f
            f_1D = f["f_1D"]
        end
    end

    f_2D = nothing
    filepath = "JLD2_save/$(file)_2D_parameters.jld2"
    if isfile(filepath)
        println("Get 2D_parameters")
        jldopen(filepath, "r") do f
            f_2D = f["f_2D"]
        end
    end

    r_1D = nothing
    filepath = "JLD2_save/$(file)_1D_result.jld2"
    if isfile(filepath)
        println("Get 1D_result")
        jldopen(filepath, "r") do f
            r_1D = f["r_1D"]
        end
    end

    r_2D_I = nothing
    filepath = "JLD2_save/$(file)_2D_result_I.jld2"
    if isfile(filepath)
        println("Get 2D_result_I")
        jldopen(filepath, "r") do f
            r_2D_I = f["r_2D_I"]
        end
    end

    r_2D_freq = nothing
    filepath = "JLD2_save/$(file)_2D_result_freq.jld2"
    if isfile(filepath)
        println("Get 2D_result_freq")
        jldopen(filepath, "r") do f
            r_2D_freq = f["r_2D_freq"]
        end
    end

    println("End Loading")

    return f_1D, f_2D, r_1D, r_2D_I, r_2D_freq
end

function main()

    file = "DIV0_default"
    f_1D, f_2D, r_1D, r_2D_I, r_2D_freq = load_file(file)

    println(propertynames(f_1D))
    print("finish")

end

main()