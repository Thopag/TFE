export plot_SS_function, plot_tau_function, plot_availability, GHK_plot, SS_shift_plot, plot_lido_inhib, Mgblock_plot

#-------------------- Stand alone plot function --------------------#

function plot_SS_function(; file_prefix = "default")

    V = -120.0:0.5:60.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]

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

function SS_shift_plot()

    xticks = [-120, -60, 0, 60]
    yticks = [0.0, 1.0]

    V = -120.0:0.5:60.0
    shift = [0.0, 5.0, 10.0, 15.0, 20.0, 25.0]
    shift = reverse(shift)

    L = length(shift)
    palette = get_palette(L, :Greys, :grey; dark=0.95, light=0.4)
    plt = plot(xlabel="Voltage (mV)", ylabel= "SS gate variable (-)", xticks = xticks, yticks = yticks, legend=false, size=(200,150))

    plot!(plt, xtickfontsize = 6, xguidefontsize = 7)
    plot!(plt, ytickfontsize = 7, yguidefontsize = 7)

    # plot!(plt, [], [], linestyle = :dash, label="$(shift[1]) mV", color=palette[1])
    # plot!(plt, [], [], linestyle = :dash, label="$(shift[end]) mV", color=palette[end])

    vec = m7_inf.(V; shift=0.0, with_shift= true)
    plot!(plt, V, vec, linestyle = :solid, label="", color=:black)

    for (i,s) in enumerate(shift)
        c = palette[i]
        vec = h7_inf.(V; shift=s, with_shift= true)
        plot!(plt, V, vec, linestyle = :dash, label="", color=c)

        # vec = m8_inf.(V; shift=0.6 * s, with_shift= true)
        # plot!(plt, V, vec, label="", color=c)
    end
    savefig(plt, "plots/default/SS_shift.svg")
end

function plot_lido_inhib()

    C = 10 .^ range(log10(0.1), log10(100000), length=1000)

    results = get_lidocaine_inhibition.(C)

    inhibition_1_3 = [r[1] for r in results]
    inhibition_1_7 = [r[2] for r in results]
    inhibition_1_8 = [r[3] for r in results]
    inhibition_NMDA = [r[4] for r in results]

    plt = plot(ylabel="Inhibition (%)", xlabel="Lidocain (µM)", xscale=:log10, legendfontsize=10, legend=:topleft)
    xticks!(plt, [0.1, 1.0, 10.0,100.0,1000.0,10000.0, 100000.0])

    plot!(plt, C, inhibition_1_3, label="NaV1.3", color=gate_colors["m3"])
    plot!(plt, C, inhibition_1_7, label="NaV1.7", color=gate_colors["m7"])
    plot!(plt, C, inhibition_1_8, label="NaV1.8", color=gate_colors["m8"])
    plot!(plt, C, inhibition_NMDA, label="NMDA", color=:blue, linestyle=:dash)
    
    savefig(plt, "plots/default/lido_inhibition.pdf")
end

function Mgblock_plot()

    V = -100.0:0.5:45.0
    xticks = [-120, -90, -60, -30, 0, 30, 60]
    plt = plot(xticks= xticks)

    xlabel!(plt, "Voltage (mV)")
    ylabel!(plt, "Mgblock (-)")

    g(x) = NMDA_Mg_block(x)
    f(x) = NMDA_Mg_block(x; shift=25.0 ,with_shift=true)

    plot!(plt, V, f.(V), color=:red, label="", linewidth=2)
    plot!(plt, V, g.(V), color=:black, label="", linewidth=2)

    savefig(plt, "plots/default/random.pdf")
end

# --------- trash --------- #

function plot_3D_plane(f_2D::File2D, results::FrequencyPlanResults, data::FrequencyPlanData, exct_data::Union{Nothing,CurrentPlanData}, file_prefix)

    spiking_filter = true

    cs = get(colorschemes[:rainbow], range(0.01, 0.99, length=256))
    cmap = cgrad(cs, 25, categorical = true)
    clip = :native #(0.0, 200.0)

    VEC_amp = results.VEC_amp

    VEC_row_param = f_2D.VEC_row_param
    VEC_col_param = f_2D.VEC_col_param

    row_label = f_2D.row_label
    col_label = f_2D.col_label

    # Accumulators for flat 1D vectors
    X_pts = Float64[]
    Y_pts = Float64[]
    Z_pts = Float64[]
    I_pts = Float64[]

    for (k,amp) in enumerate(VEC_amp)

        M_freq = data.VEC_M_freq[k]

        if !isnothing(exct_data) && spiking_filter
            M_spiking = exct_data.M_spiking
            filter = Int.(M_spiking .<= amp)
            M_freq = M_freq .* filter
        end
    
        for (i,x_i) in enumerate(VEC_col_param)
            for (j,y_j) in enumerate(VEC_row_param)
                push!(X_pts, x_i)
                push!(Y_pts, y_j)
                push!(Z_pts, amp)

                # Your 4th value (intensity) at (x_i, y_j, z_val)
                val = M_freq[j,i]
                push!(I_pts, val)
            end
        end
    end

    # Single 3D scatter plot
    plt = scatter(
        X_pts, Y_pts, Z_pts,
        marker_z = I_pts,       # Color by intensity
        color = cmap,
        markersize = 4,
        markerstrokewidth = 1,
        alpha = 0.5,
        clim=clip,
        xlabel=col_label, ylabel=row_label, zlabel="DRG stimulation (pA)",
        label="",
        camera=(30,30)
    )
    display(plt)
end