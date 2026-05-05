

function parameter_analyses(params, analysed_values; duration = 1700.0, 
                        unit="pA", param_name="amp", title="title")

    u0 = get_u0()

    println("------ Start parameter analyses ------")
    println("title : $title")
    println("Duration : $duration ms")
    println("Analysed values is $param_name : $analysed_values $unit")

    L = length(params)
    VEC_peak_count = Vector{Int}()
    VEC_freq = Vector{Float32}()
    VEC_pattern = Vector{Int}()
    VEC_first_peak_h = Vector{Float32}()
    VEC_first_peak_w = Vector{Float32}()

    for (i,param) in enumerate(params)
        print("\rProgress: $(round((i/L*100), digits=2)) %")

        # -- Make Simulation -- #

        t,V,m3,h3,m7,h7,m8,h8,ndr,ldr,nm,z_AHP,Inoise,n_test,l_test = ODE.simulation(u0, (0.0, duration), param)

        # ---- Peak Detection ---- #

        # Peak detection
        peaks_idx, w_peaks = get_peaks(t, V;  min_h=-5.0, min_proms=10)
        t_spikes = t[peaks_idx]

        # Remove wrong peak detection that appear before stimulation
        # Strangly happend with the configuration: DIV0 at 100 pA without Na current
        peaks_idx = peaks_idx[t_spikes .> param.stim_on]
        t_spikes = t_spikes[t_spikes .> param.stim_on]

        peak_count = length(peaks_idx)
        
        """# !!! Check to remove 2nd returned value !!! #"""
        freq, _, pattern = global_pattern(t_spikes, peak_count, param.stim_on, param.stim_off)
        
        # Default values
        first_peak_height = -65.0
        first_peak_width = 0.0

        if peak_count > 0
            first_peak_height = V[peaks_idx[1]]
        end

        # if not, w_peaks = [] (see global_pattern() function)
        if pattern > 0
            first_peak_width = w_peaks[1]
        end

        push!(VEC_peak_count, peak_count)
        push!(VEC_freq, freq)
        push!(VEC_pattern, pattern)
        push!(VEC_first_peak_h, first_peak_height)
        push!(VEC_first_peak_w, first_peak_width)
    end
    println("\n------ End parameter analyses ------")

    println("\n----------------------------------------------------\n")

    return VEC_peak_count, VEC_freq, VEC_pattern, VEC_first_peak_h, VEC_first_peak_w
end