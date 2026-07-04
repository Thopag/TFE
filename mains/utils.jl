
function load_file(file)

    println("Loading...")
    
    @time data = load("JLD2_save/$(file).jld2")
    fp              = data["fp"]
    pp              = data["pp"]
    analyse_r       = data["analyse_r"]
    bifurcation_r   = data["bifurcation_r"]
    DIC_r           = data["DIC_r"]
    SS_current_r    = data["SS_current_r"]
    plan_exct       = data["plan_exct"]
    plan_freq       = data["plan_freq"]

    println("--- Loaded [$(file).jld2] ---")
    println("")
    return fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq
end

function save(file; fp=nothing, pp=nothing, analyse_r=nothing, bifurcation_r=nothing, DIC_r=nothing, SS_current_r=nothing, plan_exct=nothing, plan_freq=nothing)

    println("")
    println("----------- Start Saving -----------")
    # Mute the warning about function saving
    with_logger(ConsoleLogger(stderr, Logging.Error)) do
        @time jldsave("JLD2_save/$(file).jld2"; fp, pp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_exct, plan_freq)
    end
    println("----------- Finish Saving -----------")
end

# ------------------------- Analyses ------------------------ #

function launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)

    if isnothing(fp)
        println("(launch_analyses) NO FP")
        return
    end

    println("%%%%%%%%%%%%%%%%%%%%% LAUNCH %%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$(fp.DIV)]")
    println("Simulation of [$(fp.duration)] ms")
    println("Nociceptor is [$(fp.with_nociceptor)] and projection neuron is [$(fp.with_projection_neuron)]")
    println("")
    println("Inter parameter is [$(fp.parameter_label)]")
    println("And labels : [$(fp.VEC_label)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")
    
    # -------- Analyses -------- #

    if isnothing(analyse_r)
        analyse_r = run_parameter_analyses(fp)
    else
        println("analyse_r was already done")
    end

    if isnothing(bifurcation_r)
        bifurcation_r = run_bifurcation_analyses(fp)
    else
        println("bifurcation_r was already done")
    end

    if isnothing(DIC_r)
        DIC_r = run_DIC_analyses(fp)
    else
        println("DIC_r was already done")
    end

    if isnothing(SS_current_r)
        SS_current_r = run_SS_current_analyses(fp) 
    else
        println("SS_current_r was already done")
    end
    return analyse_r, bifurcation_r, DIC_r, SS_current_r
end

function plot_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, file_prefix)

    println("----------- Start Ploting Analyses -----------")

    # SS_current_analyses
    if !isnothing(SS_current_r)
        plot_SS_current_analyses(SS_current_r, fp; file_prefix = file_prefix)
        println("SS_current_analyses done")
    else
        println("No SS_current_analyses")
    end

    # parameter_analyses
    if !isnothing(analyse_r)
        plot_parameter_analyses(analyse_r, fp; file_prefix = file_prefix)
        println("parameter_analyses done")
    else
        println("No analyse_r")
    end

    # SS_current_analyses
    if !isnothing(bifurcation_r)
        plot_bifurcation_analyses(bifurcation_r, analyse_r, fp; file_prefix = file_prefix)
        println("bifurcation_analyses done")
    else
        println("No bifurcation_analyses")
    end

    println("----------- End Ploting Analyses -----------")
    return
end

# ------------------------- PLAN ------------------------ #

function launch_plan(pp, plan_exct, plan_freq)

    if isnothing(pp)
        println("(launch_plan) NO PP")
        return
    end

    println("%%%%%%%%%%%%%%%%%%%%% LAUNCH %%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$(pp.DIV)]")
    println("Simulation of [$(pp.duration)] ms")
    println("Nociceptor is [$(pp.with_nociceptor)] and projection neuron is [$(pp.with_projection_neuron)]")
    println("")
    println("With row [$(pp.row_label)] : [$(pp.VEC_row_param)]")
    println("With col [$(pp.col_label)] : [$(pp.VEC_col_param)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")
    
    # -------- Make Plans -------- #

    if isnothing(plan_exct)
        plan_exct = run_excitability_plan(pp)
    else
        println("plan_exct was already done")
    end

    if isnothing(plan_freq)
        plan_freq = run_frequency_plan(pp)
    else
        println("plan_freq was already done")
    end

    return plan_exct, plan_freq
end

function plot_plan(pp, plan_exct, plan_freq, file_prefix)

    println("----------- Start Ploting Excitability Plan -----------")

    # excitability_plan
    if !isnothing(plan_exct)
        plot_excitability_plan(pp, plan_exct; file_prefix = file_prefix)
        println("excitability_plan done")
    else
        println("No plan_exct")
    end

    # freq_plan
    if !isnothing(plan_freq)
        plot_frequency_plan(pp, plan_freq; file_prefix = file_prefix)
        println("frequency_plan done")
    else
        println("No plan_freq")
    end

    println("----------- End Ploting Excitability Plan -----------")

    return
end