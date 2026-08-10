include("utils.jl")

function change_fp(file, fp)

    for i in eachindex(fp.VEC_p_model)
        p_model = fp.VEC_p_model[i]
        l = p_model.lidocaine
        stim = p_model.stimulation
        new_p_model = from_model_parameter(p_model; 
                    synapse = synapse_parameter(;g_NMDA = 1.0 * (1-1.0)),
                    )
        fp.VEC_p_model[i] = new_p_model
    end
    file = "$(file)_trash"
    return file, fp
end

function change_pp(file, pp)

    for i in eachindex(pp.M_p_model)
        p_model = pp.M_p_model[i]
        l = p_model.lidocaine
        stim = p_model.stimulation
        new_p_model = from_model_parameter(p_model; 
                    stimulation = stimulation_parameter(0.0; Ihold = stim.Ihold, on = stim.on, length = stim.off - stim.on),
                    lidocaine = lidocaine_parameter(;shift_h3 = l.shift_h3,shift_h7 = l.shift_h7,shift_h8 = l.shift_h8,shift_m8 = l.shift_m8,with_shift = l.with_shift),
                    )
        pp.M_p_model[i] = new_p_model
    end
    file = "$(file)_trash"
    return file, pp
end

function remake(file)

    fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq = load_file(file)

    # results = nothing to force the remake

    if !isnothing(fp)
        file, fp = change_fp(file, fp)
        analyse_r = nothing
        save(file; fp=fp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r)
    else
        println("No fp")
    end

    if !isnothing(pp)
        file, pp = change_pp(file, pp)
        #save(file; pp=pp, plan_exct=plan_exct, plan_freq=plan_freq)
    else
        println("No pp")
    end
end

function main()

    files = ["shift/DIV0_m8_shift_0.5-NMDA"]

    for file in files
        remake(file)
    end
end

main()