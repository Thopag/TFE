
function plot_test(sol_n, sol_pn, sol_s, p_model; xlimits=(400, 1700))

    n_fig = 4
    plt = plot(layout = (n_fig, 1), link = :x, xlims=xlimits, size = (750, 230*n_fig), xaxis = nothing,
                                                                    left_margin = 5mm,
                                                                    bottom_margin = 5mm, 
                                                                    margin = 5mm)

    xticks = :native
    plot!(plt[n_fig], xaxis = "Time (ms)", xticks=xticks)

    t = sol_n.t
    V = sol_n.V

    voltage = 1
    ylabel!(plt[voltage], "Voltage (mV)", ylims=(-100,50))
    plot!(plt[voltage], t, V, color= :black, label="")

    voltage_pn = 2
    ylabel!(plt[voltage_pn], "Voltage (mV)", ylims=(-100,50))
    plot!(plt[voltage_pn], t, sol_pn.V, color= :black, label="")

    syn_curr = 3
    s_current = retrieve_synapse_currents(sol_s, p_model)
    plot!(plt[syn_curr], t, .-s_current.INMDA, label="-INMDA")
    plot!(plt[syn_curr], t, .-s_current.IAMPA, label="-IAMPA")

    syn_variables = 4
    plot!(plt[syn_variables], t, sol_s.A_NMDA,  label="A_NMDA", color= :purple)
    plot!(plt[syn_variables], t, sol_s.B_NMDA,  label="B_NMDA", color= :blue)
    plot!(plt[syn_variables], t, sol_s.Use_NMDA,  label="Use_NMDA", color= :green)
    plot!(plt[syn_variables], t, sol_s.P_NMDA,  label="P_NMDA ", color= :orange)
    plot!(plt[syn_variables], t, sol_s.B_NMDA .- sol_s.A_NMDA,  label="B_NMDA - A_NMDA", color= :red)

    # response = 4
    # t_resp, resp = TFE.reponse_time(p_model.save.t_NMDA_response, t, p_model.synapse.resp_time_NMDA)
    # plot!(plt[response], t_resp, resp,  label="response", color= :black)

    return plt
end

function main(;extra=0.0)

    print("------------------------------\n")
    with_plot = true

    duration = 15000.0
    scenario = "BT"
    file_prefix = "test_n1_n2_$scenario"

    p_noci = DIV0_parameter()
    p_stim, tstops = test_n1_n2_stimulation_parameter(;scenario = scenario)
    p_model = model_parameter(;stimulation=p_stim, nociceptor=p_noci)

    u0 = get_test_u0()
    @time sol_n, sol_pn, sol_s = test_n1_n2_simulation(u0, (0.0, duration), p_model, tstops)

    # --- Plots --- #

    if with_plot
        xlimits = (0.0, duration)
        plt = plot_test(sol_n, sol_pn, sol_s, p_model; xlimits=xlimits)

        savefig(plt, "plots/simulation/$(file_prefix).png")
        #savefig(plt, "plots/simulation/$(file_prefix).pdf")
    end

    print("------------------------------\n")
end

main()