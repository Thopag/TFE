export get_test_u0

function test_n1_u0(u0)
    V0 = -66.5
    u0[1] = V0            # V
    u0[2] = mNa_inf(V0)   # mNa
    u0[3] = hNa_inf(V0)   # hNa
    u0[4] = mdr_inf(V0)   # mdr
    u0[5] = 5.0e-5        # Ca_i
end

function get_test_u0()
    u0 = zeros(Float64, 25)
    test_n1_u0(view(u0, 1:11))
    projection_neuron_u0(view(u0, 13:17))
    synapse_u0(view(u0, 18:25))
    return u0
end