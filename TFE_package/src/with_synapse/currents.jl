

function INMDA(V, A_NMDA, B_NMDA, g_NMDA, E_NMDA)
    I = (B_NMDA-A_NMDA) * g_NMDA *NMDA_Mg_block(V)*(V-E_NMDA)   # [µA/cm^2]
    return I
end

function IAMPA(V, A_AMPA, B_AMPA, g_AMPA, E_AMPA)
    I = (B_AMPA-A_AMPA) * g_AMPA *(V-E_AMPA)                    # [µA/cm^2]
    return I
end

struct SynapseCurrent{T}
    INMDA::T
    IAMPA::T
    ICa_from_syn::T
end

function retrieve_synapse_currents(s_sol, p_model)

    # ---- #
    s = p_model.synapse
    V = s_sol.V

    tmp = INMDA.(V, s_sol.A_NMDA, s_sol.B_NMDA, s.g_NMDA, s.E_NMDA)

    projection_neuron_current = SynapseCurrent(tmp,
                                    IAMPA.(V, s_sol.A_AMPA, s_sol.B_AMPA, s.g_AMPA, s.E_AMPA),
                                    tmp .* s.ratio
                        )
    return projection_neuron_current
end
