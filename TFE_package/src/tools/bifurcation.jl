
struct BifurcationResults
    VEC_br::Vector{<:BifurcationKit.ContResult}
    param_min::Float64
    param_max::Float64
end

function bifurcation_result(VEC_p_model, param_min, param_max)

    L = length(VEC_p_model)
    VEC_br = Vector{BifurcationKit.ContResult}(undef, L)

    return BifurcationResults(VEC_br, param_min, param_max)
end

function make_bifurcation(p_model, u0, lens_param, p_min, p_max)

    u0 = u0[p_model.idx.n]
    
    prob = BifurcationProblem(bifurcation_system_nociceptor, u0, p_model, lens_param, 
        record_from_solution = (x, p; k...) -> x[:], inplace = true)

    # u0 = u0[p_model.idx.pn]
    
    # prob = BifurcationProblem(bifurcation_system_projection_neuron, u0, p_model, lens_param, 
    #     record_from_solution = (x, p; k...) -> x[:], inplace = true)

    step_scaling = 100
    opts = ContinuationPar(
        p_min = p_min, 
        p_max = p_max,
        max_steps = 10000*step_scaling ,
        dsmin = 0.01/step_scaling , 
        ds = 0.1/step_scaling ,
        dsmax = 1/step_scaling ,
        detect_bifurcation = 3,
        detect_event = 0
    )
    br = continuation(prob, PALC(), opts)

    return br
end

function fill_bifurcation_result(i::Int, results::BifurcationResults, VEC_p_model, u0, lens_param, VEC_label)

    L = length(VEC_label)
    println("$(VEC_label[i]) -- $(round(((i-1)/L*100), digits=2)) % is done")
    p_model = VEC_p_model[i]

    br = make_bifurcation(p_model, u0, lens_param, results.param_min, results.param_max)
    results.VEC_br[i] = br
    return
end

function bifurcation_analyses(fp::FileParameters, lens_param, param_min, param_max)

    u0 = fp.u0
    VEC_p_model = fp.VEC_p_model
    VEC_label = fp.VEC_label
    
    results = bifurcation_result(VEC_p_model, param_min, param_max)
    for i in 1:length(VEC_p_model)
        fill_bifurcation_result(i, results, VEC_p_model, u0, lens_param, VEC_label)
    end
    return results
end
