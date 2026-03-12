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
    first_window_count = Vector{Float32}()

    for ((i,param), analysed_value) in zip(enumerate(params), analysed_values)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = launch_simulation(u0, (0.0, duration), param)

        if with_plot_sample
            plot!(p_volt, t, V, label=L"%$analysed_value %$unit", alpha= 0.4)
        end

        peaks_idx, n_peak = get_peaks(t, V;  min_h=-30, min_proms=10)
        t_spikes = t[peaks_idx]
        freq, is_hyperexct = global_freq(t_spikes, param.stim_off)
        counts, mean_count = window_count(t_spikes, param.stim_on, param.stim_off; window_width=100)

        push!(peaks_count, n_peak)
        push!(freqs, freq)
        push!(hyperexct_vec, is_hyperexct)
        push!(first_window_count, mean_count)
        
    end
    println("\n------ End parameter analyses ------")

    if with_plot_sample
        println("Display plot sample")
        plot!(p_volt, title="$folder $title samples")
        display(p_volt)
        savefig(p_volt, "plots/$(folder)_$(param_name)_$(title)-V_sample.pdf")
    end

    println("\n----------------------------------------------------\n")

    return peaks_count, freqs, hyperexct_vec, first_window_count
end

function plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_first_window_count, all_label; xlabel="amp pA")

    println("------ Start plots ------")

    p_peaks = plot(xlabel=xlabel, ylabel= "Peaks count (-)", title="$folder peaks count")
    p_freqs = plot(xlabel=xlabel, ylabel= "Frequence (Hz)", title="$folder FI curve")
    p_window = plot(xlabel=xlabel, ylabel= "Peaks count (-)", title="$folder First window count")

    for (analysed_values, peaks_count, freqs, hyperexct_vec, first_window_count, label) in zip(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_first_window_count, all_label)

        hyperexct_form = [h == 1 ? :square : :circle for h in hyperexct_vec]

        plot!(p_peaks, analysed_values, peaks_count         , marker=hyperexct_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_freqs, analysed_values, freqs               , marker=hyperexct_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)
        plot!(p_window, analysed_values, first_window_count , marker=hyperexct_form, markersize=2, linealpha=0.5, markeralpha=0.7, label=label)

    end

    display(p_peaks)
    display(p_freqs)
    display(p_window)
    savefig(p_peaks, "plots/$(folder)-peaks-curve.pdf")
    savefig(p_freqs, "plots/$(folder)-F-I-curve.pdf")
    savefig(p_window, "plots/$(folder)-window-curve.pdf")


    println("------ End plots ------")
end

function parameter_selection(;
    stim_on = 500.0,                # ms
    stim_length = 1000.0,           # ms
    C_lido = 0                      # µM
    )

    params = Vector{Parameters}()
    amps = [80,100,120] #0:75:300
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
    plot_sample = true
    lido_concentrations = [0, 1, 10, 50, 100, 500, 1000]

    all_analysed_values = Vector{Vector{Float32}}()
    all_peaks_count = Vector{Vector{Int}}()
    all_freqs = Vector{Vector{Float32}}()
    all_hyperexct_vec = Vector{Vector{Int}}()
    all_first_window_count = Vector{Vector{Float32}}()
    all_label = Vector{String}()

    for C_lido in lido_concentrations

        params, analysed_values = parameter_selection(;C_lido=C_lido)
        peaks_count, freqs, hyperexct_vec, first_window_count = parameter_analyses(params, analysed_values; with_plot_sample=plot_sample, title="lidocaine_$(C_lido)_µM")

        label = "$C_lido µM"

        push!(all_analysed_values, analysed_values)
        push!(all_peaks_count, peaks_count)
        push!(all_freqs, freqs)
        push!(all_hyperexct_vec, hyperexct_vec)
        push!(all_first_window_count, first_window_count)
        push!(all_label, label)

        
    end
    plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_hyperexct_vec, all_first_window_count, all_label; xlabel="amp pA")
end

main()
