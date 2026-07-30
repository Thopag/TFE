include("utils.jl")

function change_fp(file, fp)

    for i in eachindex(fp.VEC_p_model)
        p_model = fp.VEC_p_model[i]
        l = p_model.lidocaine
        stim = p_model.stimulation
        new_p_model = from_model_parameter(p_model; 
                    projection_neuron = projection_neuron_parameter(;pLf = 0.0),
                    stimulation = stimulation_parameter(0.0; Ihold = stim.Ihold, on = stim.on, length = stim.off - stim.on),
                    lidocaine = lidocaine_parameter(;shift_h3 = l.shift_h3,shift_h7 = l.shift_h7,shift_h8 = l.shift_h8,shift_m8 = l.shift_m8, with_shift = l.with_shift),
                    )
        fp.VEC_p_model[i] = new_p_model
    end
    file = "$(file)"
    return file, fp, nothing, nothing, nothing, nothing
end

function change_pp(file, pp)

    for i in eachindex(pp.M_p_model)
        p_model = pp.M_p_model[i]
        l = p_model.lidocaine
        stim = p_model.stimulation
        new_p_model = from_model_parameter(p_model; 
                    projection_neuron = projection_neuron_parameter(;pLf = 0.0),
                    stimulation = stimulation_parameter(0.0; Ihold = stim.Ihold, on = stim.on, length = stim.off - stim.on),
                    lidocaine = lidocaine_parameter(;shift_h3 = l.shift_h3,shift_h7 = l.shift_h7,shift_h8 = l.shift_h8,shift_m8 = l.shift_m8,with_shift = l.with_shift),
                    )
        pp.M_p_model[i] = new_p_model
    end
    file = "$(file)"
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
        #file, pp, plan_exct, plan_freq = change_pp(file, pp)
        plan_exct, plan_freq = launch_plan(pp, plan_exct, plan_freq)
        save(file; pp=pp, plan_exct=plan_exct, plan_freq=plan_freq)
    else
        println("No pp")
    end
end

function main()

    not_now = []

    files = [
            # "DIV0_baseline",
            # "inhibition/DIV0_NaV1.8_inhib",
            # "inhibition/DIV0_NMDA_inhib",
            # "shift/DIV0_h8_shift",
            # "shift/DIV0_m8_shift",
            # "shift/DIV0_m8_h8_shift",

            "shift/DIV7_h3_shift",
            "shift/DIV7_h7_shift",
            "inhibition/DIV7_NaV1.7_inhib",
            "inhibition/DIV7_NaV1.3_inhib",

            "plan/DIV0_FREQ_inhib_NaV1.8_NMDA",
            "plan/DIV0_FREQ_inhib_NaV1.8_shift",

            "plan/DIV7_NaV1.7_shift_inhib",
            "plan/DIV7_NaV1.3_shift_inhib",
            ]

    #files = ["plan/DIV0_FREQ_inhib_NaV1.8_NMDA", "plan/DIV0_FREQ_inhib_NaV1.8_shift"]

    for file in files
        println("-------------------------------------")
        println()
        println("FILE IS $file")
        println()
        println("-------------------------------------")
        launch_from_file(file)
    end

    #launch_from_file("proj_baseline_NO_pLf")

end

main()