export run_DIC_analyses

function run_DIC_analyses(VEC_p_model, VEC_label)

    V = -120.0:0.5:60.0

    println("")
    results = DIC_analyses(V, VEC_p_model, VEC_label)
    println("-------------- DIC Done --------------")

    return results
end
