

function main()

    load_excitability_plan = false

    file = "DIV0_test_2"
    
    println("")
    println("----------- Start Loading -----------")
    @time data = load("JLD2_save/$(file).jld2")
    
    analyse_r       = data["analyse_r"]
    bifurcation_r   = data["bifurcation_r"]
    DIC_r           = data["DIC_r"]
    SS_current_r    = data["SS_current_r"]
    plan_r          = data["plan_r"]
    println("----------- End Loading -----------")

    println("")
    println("----------- Start Ploting -----------")


    if !isnothing(plan_r)
        plot_excitability_plan(plan_r; file_prefix = "default")
    else
        println("No plan_r")
    end

    if !isnothing(analyse_r)
        plot_parameter_analyses(analyse_r; file_prefix = "default")
    else
        println("No analyse_r")
    end

    println("----------- End Ploting -----------")
end

main()