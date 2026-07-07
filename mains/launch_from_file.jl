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

    #files = ["DIV0_inhib_NMDA", "DIV0_inhib_NaV1.8", "DIV0_inhib_AMPA", "DIV0_plan_inhib_NaV1.8_NMDA", "DIV0_plan_inhib_AMPA_NMDA"]

    files = ["noci/DIV0_NaV1.8_h8_shift", 
                "noci/DIV0_NaV1.8_inhib",
                "noci/DIV0_NaV1.8_m0.6_h0.4_shift",
                "noci/DIV0_NaV1.8_m8_shift",
                "noci/DIV0_NaV1.8_shift_h0.4_m0.6_inhib",
                "noci/DIV7_NaV1.3_inhib",
                "noci/DIV7_NaV1.3_shift_h_inhib",
                "noci/DIV7_NaV1.3_shift",
                "noci/DIV7_NaV1.7_inhib",
                "noci/DIV7_NaV1.7_shift_h_inhib",
                "noci/DIV7_NaV1.7_shift"]

    for file in files
        println("-------------------------------------")
        println()
        println("FILE IS $file")
        println()
        println("-------------------------------------")
        launch_from_file(file)
    end
end

main()