export run_rheobase_bar, load_rheobase_bar

function get_rheobase_vec(amps, VEC_p_model, u0, duration)

    L = length(VEC_p_model)
    VEC_rheobase = Vector{Union{Nothing,Float32}}(undef, L)

    for (i,p_model) in enumerate(VEC_p_model)
        println()
        println("$i / $L")
        VEC_rheobase[i] = find_rheobase(amps, p_model, u0, duration)
    end
    return VEC_rheobase
end

function plot_rheobase_bar(VEC_rheobase, VEC_label, inter_axe_label)

    # 1:length(VEC_label)
    # [1,4,6,8,10,12,13,14]
    take_idx = 1:length(VEC_label)

    VEC_label = VEC_label[take_idx]
    VEC_rheobase = VEC_rheobase[take_idx]

    not_nothing_idx = .!isnothing.(VEC_rheobase)
    labels_not_nothing = VEC_label[not_nothing_idx]
    bars_not_nothing = VEC_rheobase[not_nothing_idx]

    plt = plot(xlabel=inter_axe_label, ylabel="rheobase (pA)", left_margin = 5mm, bottom_margin = 5mm, margin = 5mm
                                                                                                , size = (450, 200))
    
    bar!(plt, labels_not_nothing, bars_not_nothing, label="")
    annotate!(labels_not_nothing, bars_not_nothing ./ 2, text.(string.(bars_not_nothing), :center, :center, :white, 7))

    return plt
    
end

function run_rheobase_bar(VEC_p_model, u0, duration, VEC_label, inter_axe_label; file = "default")

    amps = 0.0:1:300.0

    println("")
    println("----------- Start Rheobase Bar plot -----------")
    VEC_rheobase = get_rheobase_vec(amps, VEC_p_model, u0, duration)
    println("------------ End Rheobase Bar plot ------------")


    @time jldsave("JLD2_save/rheobase/$(file).jld2"; VEC_rheobase, VEC_p_model, VEC_label, inter_axe_label)

    plt = plot_rheobase_bar(VEC_rheobase, VEC_label, inter_axe_label)
    savefig(plt, "plots/default/$(file)_rheobases_barplot.pdf")
    return
end

function load_rheobase_bar(file)

    @time data = load("JLD2_save/rheobase/$(file).jld2")

    VEC_rheobase  = data["VEC_rheobase"]
    VEC_p_model   = data["VEC_p_model"]
    VEC_label     = data["VEC_label"]
    inter_axe_label     = data["inter_axe_label"]

    plt = plot_rheobase_bar(VEC_rheobase, VEC_label, inter_axe_label)
    savefig(plt, "plots/default/$(file)_rheobases_barplot.pdf")
    return
end