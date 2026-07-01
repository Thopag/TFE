export get_projection_neuron_u0

# use @views u0[a:b]
# to give the pointer to the sub_vector and not a copy

function projection_neuron_u0(u0)
    V0 = -85.0
    u0[1] = V0            # V
    u0[2] = mNa_inf(V0)   # mNa
    u0[3] = hNa_inf(V0)   # hNa
    u0[4] = mdr_inf(V0)   # mdr
    u0[5] = mir_inf(V0)   # mir
    u0[6] = mM_inf(V0)    # mM

    u0[7] = mLs_inf(V0)   # mLs
    u0[8] = hLs_inf(V0)   # hLs
    u0[9] = mLf_inf(V0)   # mLf
    u0[10] = hLf_inf(V0)  # hLf
    u0[11] = 5.0e-5       # Ca_i
end

function get_projection_neuron_u0()
    u0 = zeros(Float64, 11)
    projection_neuron_u0(view(u0, 1:11))
    return u0
end