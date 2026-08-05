
# 1. Fix the internal LidocaineParameters mismatch
function JLD2.rconvert(::Type{TFE_package.LidocaineParameters}, reconstructed::JLD2.ReconstructedStatic)
    return lidocaine_parameter(;
        shift_h3      = reconstructed.shift_h3,
        shift_h7      = reconstructed.shift_h7,
        shift_h8      = reconstructed.shift_h8,
        shift_m8      = reconstructed.shift_m8,
        shift_Mgblock = 0.0,
        with_shift    = reconstructed.with_shift,
    )
end

# 2. Fix the master ModelParameters mismatch
function JLD2.rconvert(::Type{TFE_package.ModelParameters}, reconstructed::JLD2.ReconstructedStatic)
    # reconstructed.lidocaine is also a ReconstructedStatic object
    old_lidocaine = reconstructed.lidocaine
    
    fixed_lidocaine = lidocaine_parameter(;
        shift_h3      = old_lidocaine.shift_h3,
        shift_h7      = old_lidocaine.shift_h7,
        shift_h8      = old_lidocaine.shift_h8,
        shift_m8      = old_lidocaine.shift_m8,
        shift_Mgblock = 0.0,
        with_shift    = old_lidocaine.with_shift,
    )

    return model_parameter(; stimulation = reconstructed.stimulation,
                    nociceptor = reconstructed.nociceptor,
                    projection_neuron = reconstructed.projection_neuron, 
                    synapse = reconstructed.synapse,
                    lidocaine = fixed_lidocaine,
                    noise = reconstructed.noise,
                    idx = reconstructed.idx,
                    )
end

function re_save(file; fp=nothing, pp=nothing, analyse_r=nothing, bifurcation_r=nothing, DIC_r=nothing, SS_current_r=nothing, plan_exct=nothing, plan_freq=nothing)

    println("")
    println("----------- Start Saving -----------")
    # Mute the warning about function saving
    with_logger(ConsoleLogger(stderr, Logging.Error)) do
        @time jldsave("JLD2_save/$(file).jld2"; fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq)
    end
    println("----------- Finish Saving -----------")
end

function convert(file)

    println("Loading...")

    # Mute the warning about function loading
    data = with_logger(ConsoleLogger(stderr, Logging.Error)) do
        @time data = jldopen("JLD2_save/$(file).jld2", "r")
    end
    fp = with_logger(ConsoleLogger(stderr, Logging.Error)) do
        fp  = data["fp"]
    end
    pp = with_logger(ConsoleLogger(stderr, Logging.Error)) do
        pp  = data["pp"]
    end
    analyse_r       = data["analyse_r"]
    bifurcation_r   = data["bifurcation_r"]
    DIC_r           = data["DIC_r"]
    SS_current_r    = data["SS_current_r"]
    plan_exct       = data["plan_exct"]
    plan_freq       = data["plan_freq"]

    close(data)
    re_save(file; fp=fp, pp=pp, analyse_r=analyse_r, bifurcation_r=bifurcation_r, DIC_r=DIC_r, SS_current_r=SS_current_r, plan_exct=plan_exct, plan_freq=plan_freq)
    return 
end

function main()

    old_version = ["DIV0_baseline",
            "DIV0_but_DIV7_Na_conductance",
            "DIV7_baseline_2x_g7_WITH_pLf",
            "proj_baseline",
            "inhibition/DIV0_NaV1.8_inhib",
            "inhibition/DIV7_NaV1.7_inhib",
            "inhibition/DIV7_NaV1.3_inhib",
            "inhibition/DIV0_NMDA_inhib",
            "shift/DIV0_h8_shift",
            "shift/DIV0_m8_h8_shift",
            "shift/DIV0_m8_shift",
            "shift/DIV7_h3_shift",
            "shift/DIV7_h7_shift",
            "shift/DIV0_m8_shift_0.5-NMDA",
            "plan/DIV0_inhib_NaV1.8_shift",
            "plan/DIV7_NaV1.7_shift_inhib",
            "plan/DIV7_NaV1.3_shift_inhib",
            "plan/DIV7_NaV1.3_NaV1.7_inhib",
            "plan/DIV0_inhib_NaV1.8_NMDA",
            "plan/DIV0_NMDA_inhib_m8_shift",
            "plan/DIV0_NMDA_inhib_h8_shift",     
            ]

    for file in old_version
        convert(file)
    end
end

main()

