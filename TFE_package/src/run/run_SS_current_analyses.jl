export run_SS_current_analyses

function run_SS_current_analyses(VEC_p_model, VEC_label)

    V = -120.0:0.5:60.0

    println("")
    results = SS_current_analyses(V, VEC_p_model, VEC_label)
    println("-------------- SS Currents Done --------------")
    return results
end
