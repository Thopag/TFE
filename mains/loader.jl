

function main()

    file = "DIV0_test"

    println("")
    println("----------- Start Loading -----------")
    @time data = load("JLD2_save/$(file).jld2")
    
    analyse_r       = data["analyse_r"]
    bifurcation_r   = data["bifurcation_r"]
    DIC_r           = data["DIC_r"]
    SS_current_r    = data["SS_current_r"]
    println("----------- End Loading -----------")

    println("")
    println("----------- Start Ploting -----------")

    if !isnothing(analyse_r)
        plot_parameter_analyses(analyse_r; file_prefix = "default")
    else
        print("No analyse_r")
    end

    println("----------- End Ploting -----------")
end

main()