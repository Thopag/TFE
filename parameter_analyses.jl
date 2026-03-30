include("DIV0/params.jl")
include("DIV7/params.jl")

folder = "DIV0"

if folder == "DIV0"
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    get_param = DIV7_parameter
    get_u0 = DIV7_u0
end

function parameter_analyses(params, analysed_values; duration = 1700.0, 
                        unit="pA", param_name="amp", title="title", with_plot_sample=false)

    u0 = get_u0()

    println("------ Start parameter analyses ------")
    println("title : $title")
    println("Duration : $duration ms")
    println("Analysed values is $param_name : $analysed_values $unit")

    if with_plot_sample
        println("With plot sample on")
        p_volt = empty_voltage_plot(; xlimits=(450, 700))
    end

    L = length(params)
    peaks_count = Vector{Int}()
    freqs = Vector{Float32}()
    pattern_vec = Vector{Int}()
    first_peak_height = Vector{Float32}()

    for ((i,param), analysed_value) in zip(enumerate(params), analysed_values)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = ODE.simulation(u0, (0.0, duration), param)

        if with_plot_sample
            plot!(p_volt, t, V, label=L"%$analysed_value %$unit", alpha= 0.55)
        end

        #--------------------------------------PEAK DETECTION--------------------------------------#
        peaks_idx, n_peak = get_peaks(t, V;  min_h=-5.0, min_proms=10)
        t_spikes = t[peaks_idx]
        freq, first_count, pattern = global_pattern(t_spikes, n_peak, param.stim_on, param.stim_off)

        peak_height = -65.0
        if pattern > 0
            peak_height = V[peaks_idx[1]]
        end

        push!(peaks_count, n_peak)
        push!(freqs, freq)
        push!(pattern_vec, pattern)
        push!(first_peak_height, peak_height)
    
    end
    println("\n------ End parameter analyses ------")

    if with_plot_sample
        println("Display plot sample")
        plot!(p_volt, title="$folder $title samples")
        display(p_volt)
        savefig(p_volt, "plots/$(folder)_$(param_name)_$(title)-V_sample.pdf")
    end

    println("\n----------------------------------------------------\n")

    return peaks_count, freqs, pattern_vec, first_peak_height
end

function parameter_selection(;
    amp = 55,
    stim_on = 500.0,                # ms
    stim_length = 1000.0,           # ms
    kwargs...
    )
    params = Vector{Parameters}()

    amps = 0:2.5:300.0
    #g_nav1p7_s = 0:50:100.0
    #C_lido_s = [0.0, 1.0, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0, 500.0, 750.0, 1000.0]

    analysed_values = amps
    for i in analysed_values
        param = get_param(i, stim_on, stim_length;
        with_noise = false,
        #C_lidocaine=i,
        #with_original=false,
        with_lido_shift=true,
        #with_inhibition=false,
        kwargs...
        )
        push!(params, param)
    end

    return params, analysed_values
end

function main()
    plot_sample = false

    # amps = [55.0]#0:25:150.0
    # labels = ["$amp pA" for amp in amps]

    lido_concentrations = [0.0, 1.0, 10.0, 50.0, 100.0, 500.0, 1000.0]
    labels = ["$C_lido" for C_lido in lido_concentrations]

    # original_vec = [true, false]
    # labels = ["Base model", "Lidocaine article"]

    # g_nav1p7_s = [0.0, 30.0, 90.0, 150.0, 640.0, 1000.0, 10000.0]
    # labels = ["$g" for g in g_nav1p7_s]

    # g_nav1p8_s = [0.0, 3.0, 9.0, 15.0, 64.0, 100.0, 1000.0]
    # labels = ["$g" for g in g_nav1p8_s]

    cycling_value_rheobases = Vector{String}()
    rheobases = Vector{Float32}()

    cycling_vec = lido_concentrations

    # labels = ["($g8, $g7)" for (g8,g7) in cycling_vec]
    
    # -------- Set up ploting -------- #

    x_lab = "amp pA"
    cycling_param_label = "Lidocaine (µM)"

    p_peaks = plot(xlabel=x_lab, ylabel= "Peaks count (-)", title="peaks count")
    p_freqs = plot(xlabel=x_lab, ylabel= "Frequence (Hz)", title="FI curve")
    p_height = plot(xlabel=x_lab, ylabel= "Height (mV)", title="First peak height")
    plt_rheo = plot(xlabel=cycling_param_label, ylabel="rheobase (pA)")#, xscale=:log10)

    p_pattern = plot(xlabel=x_lab, ylabel= cycling_param_label, title="Pattern $folder", yticks = (1:length(labels), labels), legend=:topright, legendfontsize=7)
    for (c, l) in zip(Ploting.colors_list, Ploting.label_list)
        scatter!(p_pattern, [], [], marker=:square, color = c, label = l, markersize = 4)
    end

    for (i, (cycling_param, label)) in enumerate(zip(cycling_vec, labels))

        # --------------------------------------------- Change param here !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        params, analysed_values = parameter_selection(;C_lidocaine=cycling_param) 
        peaks_count, freqs, pattern_vec, first_peak_height = parameter_analyses(params, analysed_values; 
                                                                            with_plot_sample=plot_sample, title="$(cycling_param)") #, unit="mS/cm2", param_name="g_nav1p7")

        rheobase_idx = findfirst(x -> x >= 1, pattern_vec)
        if isnothing(rheobase_idx)
            println("No spike where found with $cycling_param")
        else
            println("First spike at $(analysed_values[rheobase_idx]) pA")
            push!(cycling_value_rheobases, label)
            push!(rheobases, analysed_values[rheobase_idx])
        end

        # -------- Ploting -------- #

        pattern_form = Ploting.markers_list[pattern_vec .+ 1]
        pattern_color = Ploting.colors_list[pattern_vec .+ 1]

        plot!(p_peaks, analysed_values, peaks_count         , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_freqs, analysed_values, freqs               , marker=pattern_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_height, analysed_values, first_peak_height  , marker=:circle     , markersize=2, linealpha=0.6, markeralpha=0.7, label=label)
        bar!(p_pattern, analysed_values, fill(i+0.5, length(analysed_values)), fillto=fill(i-0.45, length(analysed_values)), 
                                                                        lw=0, linecolor=:match, bar_width=(analysed_values[1]-analysed_values[2])*1.05, label="", color=pattern_color)

    end

    bar!(plt_rheo, cycling_value_rheobases, rheobases, label="")
    # display(plt_rheo)
    savefig(plt_rheo, "plots/rheobases.pdf")

    # display(p_peaks)
    # display(p_freqs)
    # display(p_window)
    # display(p_pattern)
    savefig(p_peaks, "plots/peaks-curve.pdf")
    savefig(p_freqs, "plots/F-I-curve.pdf")
    savefig(p_height, "plots/first_peak.pdf")
    savefig(p_pattern, "plots/pattern.pdf")

end

main()
