export run_DIC_analyses

function run_DIC_analyses(fp::FileParameters)

    V = -120.0:0.5:60.0

    println("")
    results = DIC_analyses(V, fp)
    println("-------------- DIC Done --------------")

    return results
end
