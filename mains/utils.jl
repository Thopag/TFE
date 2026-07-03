
function load_file(file)

    println("Loading...")
    
    @time data = load("JLD2_save/$(file).jld2")
    fp              = data["fp"]
    analyse_r       = data["analyse_r"]
    bifurcation_r   = data["bifurcation_r"]
    DIC_r           = data["DIC_r"]
    SS_current_r    = data["SS_current_r"]
    plan_r          = data["plan_r"]

    println("--- Loaded [$(file).jld2] ---")
    println("")
    return fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r
end

function save(file; fp=nothing, analyse_r=nothing, bifurcation_r=nothing, DIC_r=nothing, SS_current_r=nothing, plan_r=nothing)

    println("")
    println("----------- Start Saving -----------")
    # Mute the warning about function saving
    with_logger(ConsoleLogger(stderr, Logging.Error)) do
        @time jldsave("JLD2_save/$(file).jld2"; fp, analyse_r, bifurcation_r, DIC_r, SS_current_r, plan_r)
    end
    println("----------- Finish Saving -----------")
end

# ------------------------- Analyses ------------------------ #

function launch_analyses(fp, analyse_r, bifurcation_r, DIC_r, SS_current_r)

    if isnothing(fp)
        println("(launch) NO FP")
        return
    end

    println("%%%%%%%%%%%%%%%%%%%%% LAUNCH %%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$(fp.DIV)]")
    println("Simulation of [$(fp.duration)] ms")
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

function plot_plan(plan_r, file_prefix)

    println("----------- Start Ploting Excitability Plan -----------")

    # excitability_plan
    if !isnothing(plan_r)
        plot_excitability_plan(plan_r; file_prefix = file_prefix)
        println("excitability_plan done")
    else
        println("No plan_r")
    end

    println("----------- End Ploting Excitability Plan -----------")

    return
end