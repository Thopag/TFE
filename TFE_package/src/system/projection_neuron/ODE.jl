
# --------------------------- Include gate's equations --------------------------- #

include("gate_variable/other_functions.jl")
include("gate_variable/Na.jl")
include("gate_variable/K_dr.jl")

include("currents.jl")

# --------------------------- ODE systems --------------------------- #

function projection_neuron_state(du,u,p; Iext=0.0, Isyn=0.0, ICa_from_syn=0.0)

    pn   = p.projection_neuron

    # --- variables --- #

    V       = u[1]
    mNa     = u[2]
    hNa     = u[3]
    mdr     = u[4]
    Ca_i    = u[5]

    # --- currents --- #

    Iion = 0.0
    Iion += INa(V, mNa, hNa, pn.g_Na, pn.E_Na)
    Iion += IK_dr_pn(V, mdr, pn.g_K_dr, pn.E_K)
    Iion += ILeak_pn(V, pn.g_Leak, pn.E_Leak)

    # --- du --- #

    du[1] = (Iext-Iion-Isyn)/pn.C

    du[2] = dot_mNa(V, mNa)
    du[3] = dot_hNa(V, hNa)
    du[4] = dot_mdr(V, mdr)

    du[5] = dot_Ca_i(Ca_i, 0.0+ICa_from_syn, pn)

    return
end

function ODE_system_projection_neuron(du,u,p,t)

    # -- Iext value -- #
    stim  = p.stimulation
    pn    = p.projection_neuron

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp)  # [pA]
    Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    # -- update projection_neuron variables -- #
    projection_neuron_state(du, u, p; Iext=Iext)
    return
end

function stochastic_system_projection_neuron(du,u,p,t)

    du[:] .= 0.0

    return
end

