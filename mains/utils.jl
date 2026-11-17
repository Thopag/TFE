
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

function save(file; f_1D=nothing, f_2D=nothing, r_1D=nothing, r_2D_I=nothing, r_2D_freq=nothing)

    println("")
    println("----------- Start Saving $(file) -----------")

    if !isnothing(f_1D)
        println("Save 1D_parameters")
        filepath = "JLD2_save/$(file)_1D_parameters.jld2"
        jldsave(filepath; f_1D)
    end

    if !isnothing(f_2D)
        println("Save 2D_parameters")
        filepath = "JLD2_save/$(file)_2D_parameters.jld2"
        jldsave(filepath; f_2D)
    end

    if !isnothing(r_1D)
        println("Save 1D_result")
        filepath = "JLD2_save/$(file)_1D_result.jld2"
        jldsave(filepath; r_1D)
    end

    if !isnothing(r_2D_I)
        println("Save 2D_result_I")
        filepath = "JLD2_save/$(file)_2D_result_I.jld2"
        jldsave(filepath; r_2D_I)
    end

    if !isnothing(r_2D_freq)
        println("Save 2D_result_freq")
        filepath = "JLD2_save/$(file)_2D_result_freq.jld2"
        jldsave(filepath; r_2D_freq)
    end

    println("----------- Finish Saving -----------")
end

# ------------------------- Print setup ------------------------ #

function print_analyses_setup(f_1D)

    if isnothing(f_1D)
        println("(print_analyses_setup) NO f_1D")
        return false
    end

    println("%%%%%%%%%%%%%%%%%%%%% LAUNCH %%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$(f_1D.DIV)]")
    println("Simulation of [$(f_1D.duration)] ms")
    println("Nociceptor is [$(f_1D.with_nociceptor)] and projection neuron is [$(f_1D.with_projection_neuron)]")
    println("")
    println("Inter parameter is [$(f_1D.parameter_label)]")
    println("And labels : [$(f_1D.VEC_label)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")

    return true
end

function print_plan_setup(f_2D)

    if isnothing(f_2D)
        println("(print_plan_setup) NO f_2D")
        return false
    end

    println("%%%%%%%%%%%%%%%%%%%%% LAUNCH %%%%%%%%%%%%%%%%%%%%%")
    println("Parameter set type : [$(f_2D.DIV)]")
    println("Simulation of [$(f_2D.duration)] ms")
    println("Nociceptor is [$(f_2D.with_nociceptor)] and projection neuron is [$(f_2D.with_projection_neuron)]")
    println("")
    println("With row [$(f_2D.row_label)] : [$(f_2D.VEC_row_param)]")
    println("With col [$(f_2D.col_label)] : [$(f_2D.VEC_col_param)]")
    println("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    println("")

    return true
end

# ------------------------- Launchers ------------------------ #

function launch_analyses(f_1D, r_1D)
    if isnothing(r_1D)
        r_1D = run_parameter_analyses(f_1D)
    else
        println("(launch_analyses) r_1D was already done")
    end
    return r_1D
end

function launch_current_plan(f_2D, r_2D_I)
    
    if isnothing(r_2D_I)
        r_2D_I = run_current_plan(f_2D)
    else
        println("(launch_current_plan) r_2D_I was already done")
    end
    return r_2D_I
end

function launch_frequency_plan(f_2D, r_2D_freq)

    if isnothing(r_2D_freq)
        r_2D_freq = run_frequency_plan(f_2D)
    else
        println("(launch_frequency_plan) r_2D_freq was already done")
    end
    return r_2D_freq
end

# ------------------------- Show ------------------------ #

function show_analyses(f_1D, r_1D, file_prefix)

    println("----------- Start Ploting Analyses -----------")

    # parameter_analyses
    if !isnothing(r_1D)
        plot_parameter_analyses(r_1D, f_1D; file_prefix = file_prefix)
    else
        println("(show_analyses) No r_1D")
    end

    println("----------- End Ploting Analyses -----------")
    return
end

function show_current_plan(f_2D, r_2D_I, file_prefix)

    println("----------- Start Ploting Current Plan -----------")

    # excitability_plan
    if !isnothing(r_2D_I)
        plot_current_plan(f_2D, r_2D_I; file_prefix = file_prefix)
    else
        println("(show_current_plan) No r_2D_I")
    end

    println("----------- End Ploting Current Plan -----------")

    return
end

function show_frequency_plan(f_2D, r_2D_freq, file_prefix)

    println("----------- Start Ploting Frequency Plan -----------")

    if !isnothing(r_2D_freq)
        plot_frequency_plan(f_2D, r_2D_freq; file_prefix = file_prefix)
    else
        println("(show_frequency_plan) No r_2D_freq")
    end

    println("----------- End Ploting Frequency Plan -----------")

    return
end