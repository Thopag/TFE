
# --------------------------- Include gate's equations --------------------------- #

include("gate_variable/other_functions.jl")
include("gate_variable/Na.jl")
include("gate_variable/K_dr.jl")
include("gate_variable/K_ir.jl")
include("gate_variable/K_M.jl")
include("gate_variable/Ca_Lf.jl")
include("gate_variable/Ca_Ls.jl")

include("currents.jl")

# --------------------------- ODE systems --------------------------- #

function projection_neuron_state(du,u,p; Iext=0.0, Isyn=0.0, ICa_from_syn=0.0)

    pn   = p.projection_neuron

    # --- variables --- #

    V    = u[1]
    mNa  = u[2]
    hNa  = u[3]
    mdr  = u[4]
    mir  = u[5]
    mM   = u[6]

    mLs  = u[7]
    hLs  = u[8]
    mLf  = u[9]
    hLf  = u[10]
    Ca_i    = u[11]

    # --- currents --- #

    I_Ca_i = ICa_Lf(V, Ca_i, mLf, hLf, pn.pLf, pn.Ca_0) + ICa_Ls(V, Ca_i, mLs, hLs, pn.pLs, pn.Ca_0)

    Iion = 0.0
    Iion += INa(V, mNa, hNa, pn.g_Na, pn.E_Na)
    Iion += IK_dr_pn(V, mdr, pn.g_K_dr, pn.E_K)
    Iion += IK_ir(V, mir, pn.g_K_ir, pn.E_K)
    Iion += IK_M_pn(V, mM, pn.g_K_M, pn.E_K)
    Iion += I_Ca_i
    Iion += ILeak_pn(V, pn.g_Leak, pn.E_Leak)

    # --- du --- #

    du[1] = (Iext-Iion-Isyn)/pn.C

    du[2] = dot_mNa(V, mNa)
    du[3] = dot_hNa(V, hNa)
    du[4] = dot_mdr(V, mdr)
    du[5] = dot_mir(V, mir)
    du[6] = dot_mM(V, mM)

    du[7] = dot_mLs(V, mLs)
    du[8] = dot_hLs(V, hLs)
    du[9] = dot_mLf(V, mLf)
    du[10] = dot_hLf(V, hLf)

    du[11] = dot_Ca_i(Ca_i, I_Ca_i+ICa_from_syn, pn)

    return
end

function ODE_system_projection_neuron(du,u,p,t)

    idx = p.idx
    # -- Iext value -- #
    stim  = p.stimulation
    pn    = p.projection_neuron

    Iext = stim.Ihold + (stim.is_activated(t)*stim.amp)  # [pA]
    Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    # -- update projection_neuron variables -- #
    projection_neuron_state(view(du, idx.pn), view(u, idx.pn), p; Iext=Iext)
    return
end

function stochastic_system_projection_neuron(du,u,p,t)

    du[:] .= 0.0
    return
end

# ----------- for bifurcation ----------- #

function bifurcation_system_projection_neuron(du,u,p)

    idx = p.idx
    # -- Iext value -- #
    stim  = p.stimulation
    pn    = p.projection_neuron

    Iext = stim.Ihold + stim.amp  # [pA]
    Iext = Iext * (10^-6) / (pn.CellArea * (10^-8))      # [µA/cm^2]

    # -- update projection_neuron variables -- #
    projection_neuron_state(view(du, idx.pn), view(u, idx.pn), p; Iext=Iext)
    return du
end