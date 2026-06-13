export get_synapse_u0

# use @views u0[a:b]
# to give the pointer to the sub_vector and not a copy
function synapse_u0(u0)
    u0[1] = 0.0         # A_NMDA
    u0[2] = 0.0         # B_NMDA
    u0[3] = 0.0         # Use_NMDA
    u0[4] = 1.0         # P_NMDA
    u0[5] = 0.0         # A_AMPA
    u0[6] = 0.0         # B_AMPA
    u0[7] = 0.0         # Use_AMPA
    u0[8] = 1.0         # P_AMPA
    return
end

function get_synapse_u0(nociceptor_u0)
    u0 = zeros(Float64, 25)
    nociceptor_u0(view(u0, 1:11))
    projection_neuron_u0(view(u0, 12:16))
    synapse_u0(view(u0, 17:24))
    return u0
end