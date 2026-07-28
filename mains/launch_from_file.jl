include("utils.jl")

function change_fp(file, fp)

    for i in eachindex(fp.VEC_p_model)
        p_model = fp.VEC_p_model[i]
        new_p_model = from_model_parameter(p_model; 
                    projection_neuron=projection_neuron_parameter(;pLf = 0.0)
                    )
        fp.VEC_p_model[i] = new_p_model
    end
    file = "$(file)_NO_pLf"
    return file, fp, nothing, nothing, nothing, nothing
end

function change_pp(file, pp)

    for i in eachindex(pp.M_p_model)
        p_model = pp.M_p_model[i]
        new_p_model = from_model_parameter(p_model; 
                    projection_neuron=projection_neuron_parameter(;pLf = 0.0)
                    )
        pp.M_p_model[i] = new_p_model
    end
    file = "$(file)_NO_pLf"
    return file, pp, nothing, nothing
end

function launch_from_file(file)

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)
    
    # results = nothing to force the remake

    if !isnothing(fp)
        #file, fp, analyse_r, bifurcation_r, DIC_r, SS_current_r = change_fp(file, fp)
        analyse_r, bifurcation_r, DIC_r, SS_current_r = launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
    else
        println("No fp")
    end

    if !isnothing(pp)
        #file, fp, plan_exct, plan_freq = change_pp(file, pp)
        plan_exct, plan_freq = launch_plan(pp, plan_exct, plan_freq)
        save(file; pp=pp, plan_exct=plan_exct, plan_freq=plan_freq)
    else
        println("No pp")
    end  
end

function main()

    inhib_files = [
            # "inhibition/DIV0_NaV1.8_inhib",
            # "inhibition/DIV7_NaV1.7_inhib",
            # "inhibition/DIV7_NaV1.3_inhib",
            "inhibition/DIV0_NMDA_inhib"
            ]

    files = ["plan/DIV0_FREQ_inhib_NaV1.8_NMDA", "plan/DIV0_FREQ_inhib_NaV1.8_shift"]

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