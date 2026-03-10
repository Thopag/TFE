include("DIV0/params.jl")
include("DIV7/params.jl")

folder = "DIV0"

if folder == "DIV0"
    launch_simulation = ODE_DIV0.simulation
    get_param = DIV0_parameter
    get_u0 = DIV0_u0
elseif folder == "DIV7"
    launch_simulation = ODE_DIV7.simulation
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
        p_volt = empty_voltage_plot()
    end

    L = length(params)
    peaks_count = Vector{Int}()
    freqs = Vector{Float32}()
    hyperexct_vec = Vector{Int}()

    for ((i,param), analysed_value) in zip(enumerate(params), analysed_values)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), param)

        if with_plot_sample
            plot!(p_volt, t, V, label=L"%$analysed_value %$unit", alpha= 1)
        end

        peaks_idx, n_peak = get_peaks(t, V;  min_h=-30)
        t_spikes = t[peaks_idx]
        freq, is_hyperexct = global_freq(t_spikes, param.stim_off)

        push!(peaks_count, n_peak)
        push!(freqs, freq)
        push!(hyperexct_vec, is_hyperexct)
    end
    println("\n------ End parameter analyses ------")

    if with_plot_sample
        println("Display plot sample")
        plot!(p_volt, title="$folder $title samples")
        display(p_volt)
        savefig(p_volt, "plots/$(folder)_$(param_name)_$(title)-V_sample.pdf")
    end

    println("\n----------------------------------------------------\n")

    return peaks_count, freqs, hyperexct_vec
end

function plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_label; xlabel="amp pA")

    println("------ Start plots ------")

    p_peaks = plot(xlabel=xlabel, ylabel= "Peaks count (-)", title="$folder peaks count")
    p_freqs = plot(xlabel=xlabel, ylabel= "Frequence (Hz)", title="$folder FI curve")

    for (analysed_values, peaks_count, freqs, hyperexct_vec, label) in zip(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_label)

        hyperexct_colors = [h == 1 ? :red : :blue for h in hyperexct_vec]

        plot!(p_peaks, analysed_values, peaks_count, color=:black, label="", alpha=0.3)
        scatter!(p_peaks, analysed_values, peaks_count, markerstrokecolor=hyperexct_colors, markersize=2.5, markerstrokewidth = 0.75, label=label)

        plot!(p_freqs, analysed_values, freqs, color=:black, label="", alpha=0.3)
        scatter!(p_freqs, analysed_values, freqs, markerstrokecolor=hyperexct_colors, markersize=2.5, markerstrokewidth = 0.75, label=label)

    end

    display(p_peaks)
    display(p_freqs)
    savefig(p_peaks, "plots/$(folder)-peaks-curve.pdf")
    savefig(p_freqs, "plots/$(folder)-F-I-curve.pdf")

    println("------ End plots ------")
end

function parameter_selection(;
    stim_on = 500.0,                # ms
    stim_length = 1000.0,           # ms
    C_lido = 0                      # µM
    )

    params = Vector{Parameters}()
    amps = 0:1:120
    for amp in amps
        param = get_param(amp, stim_on, stim_length;
        with_noise = false,
        C_lidocaine=C_lido
        )
        push!(params, param)
    end

    analysed_values = amps

    return params, analysed_values
end

function main()
    plot_sample = false
    lido_concentrations = [0, 1, 10, 100, 1000]

    all_analysed_values = Vector{Vector{Float32}}()
    all_peaks_count = Vector{Vector{Int}}()
    all_freqs = Vector{Vector{Float32}}()
    all_hyperexct_vec = Vector{Vector{Int}}()
    all_label = Vector{String}()

    for C_lido in lido_concentrations

        params, analysed_values = parameter_selection(;C_lido=C_lido)
        peaks_count, freqs, hyperexct_vec = parameter_analyses(params, analysed_values; with_plot_sample=plot_sample, title="lidocaine_$(C_lido)_µM")

        label = "$C_lido µM"

        push!(all_analysed_values, analysed_values)
        push!(all_peaks_count, peaks_count)
        push!(all_freqs, freqs)
        push!(all_hyperexct_vec, hyperexct_vec)
        push!(all_label, label)
    end
    plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_label; xlabel="amp pA")
end

main()
