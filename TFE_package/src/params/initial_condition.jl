export DIV0_u0, DIV7_u0

function DIV0_u0()

    u0 = zeros(12)

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
    u0[12] = 0.0          # Inoise

    return u0
end

function DIV7_u0()

    u0 = zeros(12)

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
    u0[12] = 0.0          # Inoise

    return u0
end