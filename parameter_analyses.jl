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
        p_volt = empty_voltage_plot()
    end

    L = length(params)
    peaks_count = Vector{Int}()
    freqs = Vector{Float32}()
    pattern_vec = Vector{Int}()
    first_window_count = Vector{Float32}()

    for ((i,param), analysed_value) in zip(enumerate(params), analysed_values)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = ODE.simulation(u0, (0.0, duration), param)

        if with_plot_sample
            plot!(p_volt, t, V, label=L"%$analysed_value %$unit", alpha= 0.4)
        end

        peaks_idx, n_peak = get_peaks(t, V;  min_h=-30, min_proms=10)
        t_spikes = t[peaks_idx]
        freq, first_count, pattern = global_pattern(t_spikes, n_peak, param.stim_on, param.stim_off)

        push!(peaks_count, n_peak)
        push!(freqs, freq)
        push!(pattern_vec, pattern)
        push!(first_window_count, first_count)
        
    end
    println("\n------ End parameter analyses ------")

    if with_plot_sample
        println("Display plot sample")
        plot!(p_volt, title="$folder $title samples")
        display(p_volt)
        savefig(p_volt, "plots/$(folder)_$(param_name)_$(title)-V_sample.pdf")
    end

    println("\n----------------------------------------------------\n")

    return peaks_count, freqs, pattern_vec, first_window_count
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

    # lido_concentrations = [0.0, 1.0, 10.0, 50.0, 100.0, 500.0, 1000.0]
    # labels = ["$C_lido µM" for C_lido in lido_concentrations]

    original_vec = [true, false]
    labels = ["Original", "Article"]

    all_analysed_values = Vector{Vector{Float32}}()
    all_peaks_count = Vector{Vector{Int}}()
    all_freqs = Vector{Vector{Float32}}()
    all_pattern_vec = Vector{Vector{Int}}()
    all_first_window_count = Vector{Vector{Float32}}()
    all_params = Vector{Vector{Parameters}}()

    cycling_vec = original_vec

    for cycling_param in cycling_vec

        params, analysed_values = parameter_selection(;with_original=cycling_param)
        peaks_count, freqs, pattern_vec, first_window_count = parameter_analyses(params, analysed_values; 
                                                                            with_plot_sample=plot_sample, title="$(cycling_param)") #, unit="mS/cm2", param_name="g_nav1p7")

        push!(all_analysed_values, analysed_values)
        push!(all_peaks_count, peaks_count)
        push!(all_freqs, freqs)
        push!(all_pattern_vec, pattern_vec)
        push!(all_first_window_count, first_window_count)
        push!(all_params, params)

    end
    plot_analyses(all_analysed_values, all_peaks_count, all_freqs, all_pattern_vec, all_first_window_count, labels; xlabel="amp pA")
    #plot_param_plan(all_params, all_pattern_vec, labels)
end

main()
