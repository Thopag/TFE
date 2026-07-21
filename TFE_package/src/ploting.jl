export reponse_time, plot_SS_function, plot_tau_function, plot_availability, GHK_plot

const pattern_list   = ["No spike"    , "Single spike", "Two spikes", "Transient" , "Spiking" ]
const markers_list   = [:circle       , :utriangle    , :dtriangle  , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :yellowgreen, :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

const label_bif_specialpoint = Dict{Symbol, String}(:hopf => "Hopf", :bp => "Branch Point", :endpoint => "End Point")

function get_palette(L, colors, color; dark=0.95, light=0.4)

    if L == 1
        return [color]
    end
    return [get(colorschemes[colors], i) for i in range(light, stop=dark, length=L)]
end

function reponse_time(t_resp, sol_t)
    mask = [any(tp == t for tp in t_resp) for t in sol_t]
    return sol_t, Int.(mask)
end

function annotate_amp(plt, amp)
    xlims = Plots.xlims(plt)
    ylims = Plots.ylims(plt)
    annotate!(plt,
        xlims[2] - 0.025*(xlims[2]-xlims[1]),
        ylims[2] - 0.025*(ylims[2]-ylims[1]),
        text("$amp pA", 11, :black))
    return
end

const n_gates_labels = ["m3", "h3", "m7", "h7", "m8", "h8", "ldr", "ndr", "nM", "zAHP"]
const n_gates_colors = [:blue, :blue, :red, :red, :green, :green, :orange, :orange, :purple, :brown]
const n_gates_style  = [:solid, :dash, :solid, :dash, :solid, :dash, :dash, :solid, :solid, :solid]
const n_gates_SS_labels = [L"m_{3,\infty}", L"h_{3,\infty}", L"m_{7,\infty}", L"h_{7,\infty}", L"m_{8,\infty}", L"h_{8,\infty}", L"l_{dr,\infty}", L"n_{dr,\infty}", L"n_{M,\infty}", L"z_{AHP,\infty}"]
const n_gates_tau_labels = [L"\tau_{m_3}", L"\tau_{h_3}", L"\tau_{m_7}", L"\tau_{h_7}", L"\tau_{m_8}", L"\tau_{h_8}", L"\tau_{l_{dr}}", L"\tau_{n_{dr}}", L"\tau_{n_M}", L"\tau_{z_{AHP}}"]

const pn_gates_labels = ["mNa", "hNa", "mdr", "mir", "mM", "mLf", "hLf", "mLs", "hLs"]
const pn_gates_colors = [:firebrick, :firebrick, :orange, :yellow3, :orchid, :turquoise, :turquoise, :teal, :teal]
const pn_gates_style  = [:solid, :dash, :solid, :solid, :solid, :solid, :dot, :solid, :dash]
const pn_gates_SS_labels = [L"m_{Na,\infty}", L"h_{Na,\infty}", L"m_{dr,\infty}", L"m_{ir,\infty}", L"m_{M,\infty}", L"m_{Lf,\infty}", L"h_{Lf,\infty}", L"m_{Ls,\infty}", L"h_{Ls,\infty}"]
const pn_gates_tau_labels = [L"\tau_{m_{Na}}", L"\tau_{h_{Na}}", L"\tau_{m_{dr}}", L"\tau_{m_{ir}}", L"\tau_{m_{M}}", L"\tau_{m_{Lf}}", L"\tau_{h_{Lf}}", L"\tau_{m_{Ls}}", L"\tau_{h_{Ls}}"]

const gate_colors = Dict(key => color for (key, color) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_colors, pn_gates_colors)))
const gate_styles = Dict(key => style for (key, style) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_style, pn_gates_style)))
const gates_SS_labels = Dict(key => color for (key, color) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_SS_labels, pn_gates_SS_labels)))
const gates_tau_labels = Dict(key => style for (key, style) in zip(vcat(n_gates_labels, pn_gates_labels), vcat(n_gates_tau_labels, pn_gates_tau_labels)))

#-------------------- Stand alone plot function --------------------#

function plot_SS_function(; file_prefix = "default")

    V = -120.0:0.5:60.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]

    # In the futur : add the adaptation with p_model

    p_n = plot(xlabel="Voltage (mV)", ylabel= "(-)", legendfontsize=11, legend=:right
                                        , xticks = xticks)

    p_pn = plot(xlabel="Voltage (mV)", ylabel= "(-)", legendfontsize=11, legend=:right
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

    for l in n_gates_labels[1:6]
        c     = gate_colors[l]
        style = gate_styles[l]
        lab = gates_SS_labels[l]
        vec   = n_gate_values[l]
        plot!(p_n, V, vec, label=lab, color=c, linestyle=style, linewidth=2)
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

    pn_gates = [mNa, hNa, mdr, mir, mM, mLf, hLf, mLs, hLs]
    pn_gate_values = Dict(key => vec for (key, vec) in zip(pn_gates_labels, pn_gates))

    for l in pn_gates_labels[6:end]
        c     = gate_colors[l]
        style = gate_styles[l]
        lab = gates_SS_labels[l]
        vec   = pn_gate_values[l]
        plot!(p_pn, V, vec, label=lab, color=c, linestyle=style, linewidth=2)
    end

    #savefig(p_n, "plots/default/$(file_prefix)_SS_gates_n.pdf")
    savefig(p_pn, "plots/default/$(file_prefix)_SS_gates_pn.pdf")
end

function plot_tau_function(; file_prefix = "default")

    V = -120.0:0.5:60.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    yticks = [0.01, 0.1, 1.0, 10.0, 100.0, 1000.0, 10000.0]

    ylims = [0.001, 50000.0]
    
    # In the futur : add the adaptation with p_model

    p_n = plot(xlabel="Voltage (mV)", ylabel= "Time (ms)", legendfontsize=11, legend=:bottom
                                        , xticks = xticks, yscale=:log10, yticks = yticks, ylims = ylims)

    p_pn = plot(xlabel="Voltage (mV)", ylabel= "Time (ms)", legendfontsize=11, legend=:topright
                                        , xticks = xticks, yscale=:log10, yticks = yticks,ylims = ylims)

    m3 = tau_m3.(V)
    h3 = tau_h3.(V)
    m7 = tau_m7.(V)
    h7 = tau_h7.(V)
    m8 = tau_m8.(V)
    h8 = tau_h8.(V)
    nM = tau_nM.(V)
    ndr = tau_ndr.(V)
    ldr = tau_ldr.(V)
    zAHP = tau_zAHP.(V)

    n_gates = [m3, h3, m7, h7, m8, h8, ldr, ndr, nM, zAHP]
    n_gate_values = Dict(key => vec for (key, vec) in zip(n_gates_labels, n_gates))

    for l in n_gates_labels[7:end]
        c     = gate_colors[l]
        style = gate_styles[l]
        lab   = gates_tau_labels[l]
        vec   = n_gate_values[l]
        plot!(p_n, V, vec, label=lab, color=c, linestyle=style, linewidth=2)
    end

    mNa = tau_mNa.(V)
    hNa = tau_hNa.(V)
    mdr = tau_mdr.(V)
    mir = tau_mir.(V)
    mM  = tau_mM.(V)

    mLf = tau_mLf.(V)
    hLf = tau_hLf.(V)
    mLs = tau_mLs.(V)
    hLs = tau_hLs.(V)

    pn_gates = [mNa, hNa, mdr, mir, mM, mLf, hLf, mLs, hLs]
    pn_gate_values = Dict(key => vec for (key, vec) in zip(pn_gates_labels, pn_gates))

    for l in pn_gates_labels[6:end]
        c     = gate_colors[l]
        style = gate_styles[l]
        lab = gates_tau_labels[l]
        vec   = pn_gate_values[l]
        plot!(p_pn, V, vec, label=lab, color=c, linestyle=style, linewidth=2)
    end
    #savefig(p_n, "plots/default/$(file_prefix)_tau_gates_n.pdf")
    savefig(p_pn, "plots/default/$(file_prefix)_tau_gates_pn.pdf")
end

function plot_availability(; file_prefix = "default")

    V = -100.0:0.5:45.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]

    p_n = plot(xlabel="Voltage (mV)", ylabel= "Availability (-)", legendfontsize=9, legend=:topleft
                                        , xticks = xticks, size = (600, 200), left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)

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

    plot!(p_n, V, m3.^3 .* h3 ./ maximum(m3.^3 .* h3), label="NaV1.3", color=gate_colors["m3"], linewidth = 3)
    plot!(p_n, V, m7.^3 .* h7 ./ maximum(m7.^3 .* h7), label="NaV1.7", color=gate_colors["m7"], linewidth = 3)
    plot!(p_n, V, m8.^3 .* h8 ./ maximum(m8.^3 .* h8), label="NaV1.8", color=gate_colors["m8"], linewidth = 3)

    savefig(p_n, "plots/default/$(file_prefix)_availability.pdf")
end

function GHK_plot()

    Ca_o = 2.0
    V = -60:0.5:50
    VEC_Ca_i = [5.0e-5, 5.0e-2, 0.1, 0.5, 1.0, 1.5, 2.0]
    VEC_color = palette(:rainbow, length(VEC_Ca_i))

    plt = plot(xticks= -60:20:40)

    xlabel!(plt, "Voltage (mV)")
    ylabel!(plt, "GHK (mC/cm3)")

    hline!(plt, [0], color=:black, linestyle=:dot, linewidth=2, label="")
    for (Ca_i, c) in zip(VEC_Ca_i, VEC_color)
        GHK = ghk_LeFranc.(V, Ca_i, Ca_o)
        plot!(plt, V, GHK, color=c, label="$Ca_i mM", linewidth=2)
    end  

    savefig(plt, "plots/default/GHK.pdf")
end