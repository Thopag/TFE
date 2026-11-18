

const pattern_list   = ["No spike"    , "Single spike", "Depolarization Block" , "Sustained Spiking" ]
const markers_list   = [:circle       , :utriangle    , :diamond    , :square   ]
const colors_list    = [:midnightblue , :darkgreen    , :orange     , :red3     ]

const pattern_palette = cgrad(colors_list, categorical = true)

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

function get_palette(L, colors, color; dark=0.95, light=0.4)
    if L == 1
        return [color]
    end
    return [get(colorschemes[colors], i) for i in range(light, stop=dark, length=L)]
end

function make_heatmap(M, x_values, y_values, x_label, y_label, clip, cmap)

    m = 400
    size = ( 1.05 * m, m)

    # Manage the heatmap edges
    diff_x = abs(x_values[2]-x_values[1])
    diff_y = abs(y_values[2]-y_values[1])

    x_limits = (x_values[1] -diff_x/8, x_values[end] + diff_x/8)
    y_limits = (y_values[1] -diff_y/8, y_values[end] + diff_y/8)

    # make the heatmap
    plt = plot(xlabel=x_label, ylabel=y_label, size=size)

    heatmap!(plt, x_values, y_values, M, background_color_inside = :black, c = cmap, clims=clip)
    plot!(plt, xlims=x_limits, ylims=y_limits)

    return plt
end

# ---------- Current space ---------- #

function compute_in_out_Iions(Iion_s)
    ## Compute in and out currents vector for each "complete" current vector in soma
    VEC_Iion_in = []
    VEC_Iion_out = []
    for i in eachindex(Iion_s)
        Iion_in = zeros(size(Iion_s[i]))
        Iion_in[Iion_s[i].<0]  .= Iion_s[i][Iion_s[i].<0] #Negative current is inward
    
        Iion_out = zeros(size(Iion_s[i])) 
        Iion_out[Iion_s[i].>0] .= Iion_s[i][Iion_s[i].>0] #Positive current is outward
        push!(VEC_Iion_in,Iion_in)
        push!(VEC_Iion_out,Iion_out)
    end
    
    ## Compute total in and out currents in soma 
    sum_Iion_in = sum(VEC_Iion_in) #[µA/cm²] 
    sum_Iion_out = sum(VEC_Iion_out) #[µA/cm²] 

    ## Convert the 0 to avoid NaN in the further ratio computation
    replace!(sum_Iion_in, 0.0 => 1e-6)
    replace!(sum_Iion_out, 0.0 => 1e-6)

    return VEC_Iion_in, VEC_Iion_out, sum_Iion_in, sum_Iion_out
end

function add_in_out_ratios(plt_in, plt_out, t, VEC_Iion_in, sum_Iion_in, VEC_Iion_out, sum_Iion_out, Iion_colors, Iion_labels)

    add_in = false
    if !isnothing(plt_in)
        add_in = true
        plot!(plt_in, ylabel="% in", grid=:none)
        plot!(plt_in, legend=:topleft, fontfamily="Computer Modern")
    end

    add_out = false
    if !isnothing(plt_out)
        add_out = true
        plot!(plt_out, ylabel="% out", grid=:none)
        plot!(plt_out, legend=:topleft, fontfamily="Computer Modern")
    end

    sum_in_cumul = zeros(size(VEC_Iion_in[1]))
    previous_ratio_in_cumul = zeros(size(VEC_Iion_in[1]))

    sum_out_cumul = zeros(size(VEC_Iion_out[1]))
    previous_ratio_out_cumul = zeros(size(VEC_Iion_out[1]))

    for i in eachindex(VEC_Iion_in)

        # -- Inward currents -- #
        if add_in
            sum_in_cumul = VEC_Iion_in[i] .+ sum_in_cumul
            ratio_in_cumul = abs.( sum_in_cumul ./ sum_Iion_in )
            ratio_in_i = abs.( VEC_Iion_in[i] ./ sum_Iion_in )

            if maximum(ratio_in_i) > 1e-6
                plot!(plt_in,t,ratio_in_cumul, fillrange=previous_ratio_in_cumul, fillcolor=Iion_colors[i], label=Iion_labels[i], lc=Iion_colors[i], fillalpha=0.95, ylims=(-0.03,1))
            end
            previous_ratio_in_cumul = ratio_in_cumul
        end

        # -- Outward currents -- #
        if add_out
            sum_out_cumul = VEC_Iion_out[i] .+ sum_out_cumul
            ratio_out_cumul = abs.( sum_out_cumul ./ sum_Iion_out )
            ratio_out_i = abs.( VEC_Iion_out[i] ./ sum_Iion_out )
            if maximum(ratio_out_i) > 1e-6
                plot!(plt_out,t,ratio_out_cumul, fillrange=previous_ratio_out_cumul, fillcolor=Iion_colors[i], label=Iion_labels[i], lc=Iion_colors[i], fillalpha=0.95, ylims=(-0.03,1))
            end
            previous_ratio_out_cumul = ratio_out_cumul
        end
    
    end
    return plt_in, plt_out
end

function add_current_space(plt_in, plt_out, t, Iion_s, pal_Iion, lab_Ix)
    VEC_Iion_in, VEC_Iion_out, sum_Iion_in, sum_Iion_out = compute_in_out_Iions(Iion_s)
    add_in_out_ratios(plt_in, plt_out, t, VEC_Iion_in, sum_Iion_in, VEC_Iion_out, sum_Iion_out, pal_Iion, lab_Ix)
    return
end