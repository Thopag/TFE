export run_bifurcation_analyses

function run_bifurcation_analyses(u0, VEC_p_model, VEC_label)
    
    L = length(u0)
    if L == 25
        u0 = u0[1:11]
    end

    # -------- bif Parameter -------- #

    lens_param = PropertyLens(:amp) ∘ PropertyLens(:stimulation)
    #lens_param = @optic _.stimulation.amp
    amp_min = -300.0
    amp_max = 300.0

    println("")
    println("----------- Start Bifurcations -----------")
    results = bifurcation_analyses(VEC_p_model, u0, lens_param, amp_min, amp_max, VEC_label)
    println("------------ End Bifurcations ------------")

    return results
end
