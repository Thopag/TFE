export DIV0_u0, DIV7_u0, get_DIV0_u0, get_DIV7_u0

# use @views u0[a:b]
# to give the pointer to the sub_vector and not a copy

function DIV0_u0(u0)
    u0[1] = -69.5         # V
    u0[2] = 0.0           # m3
    u0[3] = 0.0           # h3
    u0[4] = 0.0           # m7
    u0[5] = 0.0           # h7
    u0[6] = 0.0           # m8
    u0[7] = 0.9952        # h8
    u0[8] = 0.0           # ndr
    u0[9] = 0.6487        # ldr
    u0[10] = 0.0014       # nm 
    u0[11] = 0.0          # zAHP
    return
end

function DIV7_u0(u0)
    u0[1] = -70.0         # V
    u0[2] = 0.0           # m3
    u0[3] = 0.7191        # h3
    u0[4] = 0.0219        # m7
    u0[5] = 0.2579        # h7
    u0[6] = 0.0           # m8
    u0[7] = 0.9964        # h8
    u0[8] = 0.0           # ndr
    u0[9] = 0.6058        # ldr
    u0[10] = 0.0          # nm 
    u0[11] = 0.0          # zAHP
    return
end

function get_DIV0_u0()
    u0 = zeros(Float64, 12)
    DIV0_u0(view(u0, 1:11))
    return u0
end

function get_DIV7_u0()
    u0 = zeros(Float64, 12)
    DIV0_u7(view(u0, 1:11))
    return u0
end