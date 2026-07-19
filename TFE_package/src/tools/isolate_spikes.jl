
function get_spikes_windows(t_spikes, t, x; window_length=30)

    L = length(t_spikes)
    t_vecs = Vector{Vector{Float64}}(undef, L)
    x_vecs = Vector{Vector{Float64}}(undef, L)

    for (i, t_spike) in enumerate(t_spikes)

        start_idx = searchsortedfirst(t, t_spike)
        end_idx = searchsortedlast(t, t_spike + window_length)
        idx = start_idx:end_idx
        t_vecs[i] = t[idx] .- t_spike
        x_vecs[i] = x[idx]
    end
    return t_vecs, x_vecs
end

function plot_spikes(p_model, sol_n, sol_pn, sol_s, file_prefix)

    plt = plot(size = (600, 175), left_margin = 5mm,bottom_margin = 5mm, margin = 5mm)
    xticks = :native
    plot!(plt, xaxis = "Time (ms)", xticks=xticks, xguidefontsize = 14)

    if !isnothing(sol_n)
        t = sol_n.t
        n_current = retrieve_nociceptor_currents(sol_n, p_model)

    end

    # --------------------- PROJECTION NEURON --------------------- #
    if !isnothing(sol_pn)
        t = sol_pn.t
        pn_current = retrieve_projection_neuron_currents(sol_pn, p_model)

    end

    # --------------------- SYNAPSE --------------------- #
    if !isnothing(sol_s)
        t = sol_s.t
        s_current = retrieve_synapse_currents(sol_s, p_model)

        ylabel!(plt, "Current [µA/cm2]")
        ylims!(plt, (-3, 1))

        ICa_i = pn_current.ICa_Lf .+ pn_current.ICa_Ls
        Isyn = s_current.INMDA .+ s_current.IAMPA
        t_spikes = sol_n.t_spikes
        x = s_current.INMDA

        t_vecs, x_vecs = get_spikes_windows(t_spikes, t, x; window_length=30)
        for (ti, xi) in zip(t_vecs, x_vecs)
            plot!(plt, ti, xi, label="", color=:black, alpha= 0.5, linewidth=0.5)
        end
    end
    savefig(plt, "plots/simulation/$(file_prefix)_response.pdf")
end