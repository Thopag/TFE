
struct ExcitabilityPlanResults
    M_rheobase::Matrix{Float64}
    M_spiking::Matrix{Float64}
    VEC_amp::Vector{Float64}
    M_p_model::Matrix{ModelParameters}
    VEC_row_param::Vector{Float64}
    VEC_col_param::Vector{Float64}
    row_label::String
    col_label::String
end

function excitability_plan_result(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label)

    n_row, n_col = size(M_p_model)
    M_rheobase = Matrix{Float64}(undef, n_row, n_col)
    M_spiking = Matrix{Float64}(undef, n_row, n_col)
    return ExcitabilityPlanResults(M_rheobase, M_spiking, VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label)
end

function find_rheobase(amps, p_model, u0; duration = 1700.0)

    stim = p_model.stimulation

    is_finded = false
    rheobase = NaN64
    spiking = NaN64
    L = length(amps)
    for (i,amp) in enumerate(amps)
        print("\rProgress: $(round(((i-1)/L*100), digits=2)) %")

        # -- Make Simulation -- #
        i_stim = change_stimulation_amp(amp, stim)
        i_p_model = from_model_parameter(p_model; stimulation=i_stim)
        sol_n, _, _ = nociceptor_simulation(u0, (0.0, duration), i_p_model)

        # -- Get predicted pattern -- #
        _, pattern = get_excitability(sol.t_spikes, i_stim.off)

        # Check if there is at least one spike
        if (pattern >= 1) && (!is_finded)
            rheobase = amp
            is_finded = true
        end
        # Check if there is spiking
        if (pattern == 4)
            print("\r")
            spiking = amp
            return rheobase, spiking
        end
    end
    print("\r")
    return rheobase, spiking
end


function fill_excitability_plan_result(i::Int, j::Int, results::ExcitabilityPlanResults, u0; duration = 1700.0)

    p_model = results.M_p_model[i, j]
    VEC_amp = results.VEC_amp

    n_row, n_col = size(results.M_p_model)
    println("\r Row : $(round((((i)-1)/n_row*100), digits=2)) % ----- Col : $(round((((j)-1)/n_col*100), digits=2)) %")

    rheobase, spiking = find_rheobase(VEC_amp, p_model, u0; duration = duration)
    results.M_rheobase[i, j] = rheobase
    results.M_spiking[i, j] = spiking

    print("\r")
    return
end

function excitability_plan(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, duration, u0)

    results = excitability_plan_result(VEC_amp, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label)
    for j in axes(M_p_model, 2)
        for i in axes(M_p_model, 1)
            fill_excitability_plan_result(i, j, results, u0; duration = duration)
        end
    end
    return results
end