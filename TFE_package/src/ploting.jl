export reponse_time, plot_SS_function

const pattern_list   = ["No spike"    , "Single spike", "Two spikes", "Transient" , "Spiking" ]
const markers_list   = [:circle       , :utriangle    , :dtriangle  , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :yellowgreen, :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

function NaV_palettes(L; dark=0.95, light=0.4)

    if L == 1
        return [:red], [:blue], [:green], [:grey]
    end

    reds   = [get(colorschemes[:Reds], i)   for i in range(light, stop=dark, length=L)]
    blues  = [get(colorschemes[:Blues], i)  for i in range(light, stop=dark, length=L)]
    greens = [get(colorschemes[:Greens], i) for i in range(light, stop=dark, length=L)]
    greys  = [get(colorschemes[:Greys], i)  for i in range(light, stop=dark, length=L)]

    return reds, blues, greens, greys
end

function reponse_time(t_resp, sol_t)
    mask = [any(tp == t for tp in t_resp) for t in sol_t]
    return sol_t, Int.(mask)
end

const n_gates_labels = ["m3", "h3", "m7", "h7", "m8", "h8", "ldr", "ndr", "nM", "zAHP"]
const n_gates_colors = [:blue, :blue, :red, :red, :green, :green, :orange, :orange, :purple, :brown]
const n_gates_style  = [:solid, :dash, :solid, :dash, :solid, :dash, :dash, :solid, :solid, :solid]

const pn_gates_labels = []
const pn_gates_colors = []
const pn_gates_style  = []

const gate_colors = Dict(key => color for (key, color) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_colors, pn_gates_colors)))
const gate_styles = Dict(key => style for (key, style) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_style, pn_gates_style)))

function plot_SS_function(; file_prefix = "default")

    V = -120.0:0.5:60.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    
    # In the futur : add the adaptation with p_model

    p_n = plot(xlabel=L"Voltage ($mV$)", ylabel= L"(-)", legendfontsize=7, legend=:bottomleft
                                        , xticks = xticks)

    p_pn = plot(xlabel=L"Voltage ($mV$)", ylabel= L"(-)", legendfontsize=7, legend=:bottomright
                                        , xticks = xticks)

    m3 = m3_inf.(V)
    h3 = h3_inf.(V)
    m7 = m7_inf.(V)
    h7 = h7_inf.(V)
    m8 = m8_inf.(V)
    h8 = h8_inf.(V)
    nM = nM_inf.(V)
    ndr = ndr_inf.(V)
    ldr = ldr_inf.(V)
    zAHP = zAHP_inf.(V)

    n_gates = [m3, h3, m7, h7, m8, h8, ldr, ndr, nM, zAHP]
    n_gate_values = Dict(key => vec for (key, vec) in zip(n_gates_labels, n_gates))

    for l in n_gates_labels
        c     = gate_colors[l]
        style = gate_styles[l]
        vec   = n_gate_values[l]
        plot!(p_n, V, vec, label=l, color=c, linestyle=style)
    end

    mNa = mNa_inf.(V)
    hNa = hNa_inf.(V)
    mdr = mdr_inf.(V)
    mir = mir_inf.(V)
    mM  = mM_inf.(V)

    mLf = mLf_inf.(V)
    hLf = hLf_inf.(V)
    mLs = mLs_inf.(V)
    hLs = hLs_inf.(V)

    plot!(p_pn, V, mNa, label="mNa", linestyle=:solid)
    plot!(p_pn, V, hNa, label="hNa", linestyle=:dash)
    plot!(p_pn, V, mdr, label="mdr", linestyle=:solid)
    plot!(p_pn, V, mir, label="mir", linestyle=:solid)
    plot!(p_pn, V, mM, label="mM", linestyle=:solid)

    plot!(p_pn, V, mLf, label="mLf", linestyle=:solid)
    plot!(p_pn, V, hLf, label="hLf", linestyle=:dash)
    plot!(p_pn, V, mLs, label="mLs", linestyle=:solid)
    plot!(p_pn, V, hLs, label="hLs", linestyle=:dash)

    savefig(p_n, "plots/default/$(file_prefix)_SS_gates_n.pdf")
    savefig(p_pn, "plots/default/$(file_prefix)_SS_gates_pn.pdf")
end
