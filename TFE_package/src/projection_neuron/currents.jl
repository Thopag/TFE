export retrieve_projection_neuron_currents, projection_neuron_SS_currents

function INa(V, mNa, hNa, g_Na, E_Na)
    I = g_Na*mNa^3*hNa*(V-E_Na)               # [µA/cm^2]
    return I
end
function IK_dr_pn(V, mdr, g_K_dr, E_K)
    I = g_K_dr*mdr^4*(V-E_K)                  # [µA/cm^2]
    return I
end
function ICa_Lf(V, pLf, mLf, hLf, Ca_i, Ca_0)
    I = pLf*mLf^2*hLf*ghk_LeFranc(V, Ca_i, Ca_0) *1000  # [µA/cm^2] instead of [mA/cm^2]
    return I
end
function ICa_Ls(V, Ca_i, pLs, mLs, hLs, Ca_0)
    I = pLs*mLs*hLs*ghk_LeFranc(V, Ca_i, Ca_0) *1000    # [µA/cm^2] instead of [mA/cm^2]
    return I
end
function IK_ir(V, mir, g_K_ir, E_K)
    I = g_K_ir*mir*(V-E_K)                    # [µA/cm^2]
    return I
end
function IK_M_pn(V, mM, g_K_M, E_K)
    I = g_K_M*mM*(V-E_K)                      # [µA/cm^2]
    return I
end
function ILeak_pn(V, g_Leak, E_Leak)
    I = g_Leak*(V-E_Leak)                     # [µA/cm^2]
    return I
end

struct ProjectionNeuronCurrent{T}
    INa::T
    IK_dr::T
    ILeak::T
end

function retrieve_projection_neuron_currents(pn_sol, p_model)

    # ---- #
    pn = p_model.projection_neuron
    stim = p_model.stimulation
    V = pn_sol.V

    # Iext = stim.Ihold + (stim.is_activated(t)*stim.amp)  # [pA]
    # Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    projection_neuron_current = ProjectionNeuronCurrent(INa.(V, pn_sol.mNa, pn_sol.hNa, pn.g_Na, pn.E_Na),
                                    IK_dr_pn.(V, pn_sol.mdr, pn.g_K_dr, pn.E_K),
                                    ILeak_pn.(V, pn.g_Leak, pn.E_Leak)
                        )
    return projection_neuron_current
end

function projection_neuron_SS_currents(p_model, V)

    pn = p_model.projection_neuron

    mNa = mNa_inf.(V)
    hNa = hNa_inf.(V)
    mdr = mdr_inf.(V)

    projection_neuron_current = ProjectionNeuronCurrent(INa.(V, mNa, hNa, pn.g_Na, pn.E_Na),
                                    IK_dr_pn.(V, mdr, pn.g_K_dr, pn.E_K),
                                    ILeak_pn.(V, pn.g_Leak, pn.E_Leak)
                        )
    return projection_neuron_current
end