include("utils.jl")

include("1D_parameters.jl")
include("2D_parameters.jl")

function main()

    # -------- Network -------- #

    DIV = "DIV7"
    with_nociceptor = true
    with_projection_neuron = true

    # -------- Stimulation -------- #
 
    duration = 2000.0      # ms
    stim_on = 300.0        # ms
    stim_length = 1400.0   # ms

    amp = 100.0

    # -------- File name -------- #

    file = "$(DIV)_default"
    #file = "data/$(DIV)"

    # -------- Launching options -------- #

    launch_simulations = false
    launch_1D = true
    launch_2D = false

    # -------- PARAMETER SET TYPE -------- #

    if DIV == "DIV0"
        nociceptor_parameter = DIV0_parameter
        set_u0_noci = DIV0_u0
        get_u0_noci = get_DIV0_u0
        Ihold = 0.0 # -3.0
    elseif DIV == "DIV7"
        nociceptor_parameter = DIV7_parameter
        set_u0_noci = DIV7_u0
        get_u0_noci = get_DIV7_u0
        Ihold = 0.0
    end

    f_1D = nothing
    r_1D = nothing
    r_2D_I = nothing
    r_2D_freq = nothing

    # -------- Initial Condition -------- #

    u0 = get_synapse_u0(set_u0_noci)

    # --------------------------- Make parameters --------------------------- #

    p_stim = stimulation_parameter(amp; on=stim_on, length=stim_length, Ihold=Ihold)

    f_1D = make_1D_parameters(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)
    f_2D = make_2D_parameters(u0, duration, DIV, p_stim, nociceptor_parameter, with_nociceptor, with_projection_neuron)

    if launch_simulations
        VEC_p_model = f_1D.VEC_p_model

        VEC_p_model = [VEC_p_model[1]]
        make_simulations(VEC_p_model, u0, duration, f_1D.VEC_label, DIV, with_nociceptor, with_projection_neuron; file_prefix = file)
    end
    if launch_1D
        if print_analyses_setup(f_1D)
            save(file; f_1D=f_1D)

            # r_1D = launch_analyses(f_1D, r_1D)
            # save(file; r_1D=r_1D)
        
            # show_analyses(f_1D, r_1D, file)
        end
    end
    if launch_2D
        if print_plan_setup(f_2D)
            save(file; f_2D=f_2D)

            # r_2D_I = launch_current_plan(f_2D, r_2D_I)
            # save(file; r_2D_I=r_2D_I)
            # r_2D_freq = launch_frequency_plan(f_2D, r_2D_freq)
            # save(file; r_2D_freq=r_2D_freq)

            # show_current_plan(f_2D, r_2D_I, file)
            # show_frequency_plan(f_2D, r_2D_freq, file)
        end
    end
end

main()