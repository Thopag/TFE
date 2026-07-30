export lidocaine_parameter, get_lidocaine_inhibition, h3_shift, m3_shift, h7_shift, m7_shift, h8_shift, m8_shift

# ----------------- Lidocaine Parameter struct ----------------- #

struct LidocaineParameters
    shift_h3::Float64
    shift_h7::Float64
    shift_h8::Float64
    shift_m8::Float64
    with_shift::Bool
end

function lidocaine_parameter(;
    shift_h3 = 0.0,
    shift_h7 = 0.0,
    shift_h8 = 0.0,
    shift_m8 = 0.0,
    with_shift = false,
    )

    lidocaine = LidocaineParameters(shift_h3, shift_h7, shift_h8, shift_m8, with_shift)

    return lidocaine
end

# ----------------- Lidocaine Steady state shift----------------- #

# 1.3 inactivation
# 20 mV shift at 1000 µM (Sheets et al. 2008)
# 20.7 mV shift at 1000 µM (Lenkowski et al. 2003)
function lido_h3(C)
    return - ((-21.4 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 21.4)
end

@inline function h3_shift(shift, with_shift)
    if !with_shift
        return 0.0
    end
    return -shift
end

# 1.3 activation
@inline function m3_shift()
    return 0.0
end

# 1.7 inactivation
# 23 mV shift at 1000 µM (Sheets et al. 2008)
# 10.6 mV shift at 100 µM (Chevrier et al. 2004)
function lido_h7(C)
    return - ( (-24.2 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 24.2)
end

@inline function h7_shift(shift, with_shift)
    if !with_shift
        return 0.0
    end
    return -shift
end

# 1.7 activation
@inline function m7_shift()
    return 0.0
end

# 1.8 inactivation
# 4.8 mV shift at 1000 µM (Sheets et al. 2008)
# 4 mV shift at 100 µM (Chevrier et al. 2004)
function lido_h8(C)
    return - ( (4.8 / (1 + exp(-14.16 * (log10(C) - log10(77))))) + 0)
end

@inline function h8_shift(shift, with_shift)
    if !with_shift
        return 0.0
    end
    return -shift
end

# 1.8 activation
function lido_m8(C)
    return (-6.8 / (1 + exp(8.73 * (log10(C) - log10(56.5))))) + 6.8 
end

@inline function m8_shift(shift, with_shift)
    if !with_shift
        return 0.0
    end
    return shift
end

# ----------------- Lidocaine conductance inhibition ----------------- #

@inline hill(D, f_max, IC50, h, y0) = y0 + (f_max * D^h) / (IC50^h + D^h)

# From Chevrier et al. 2004
@inline lidocain_1_7_channel(D) = hill(D, 1.0079, 477.1, 1.31, 1.52 / 100)
@inline lidocain_1_8_channel(D) = hill(D, 0.9698, 118.31, 1.06, 4.78 / 100)

# From Sheets et al. 2008
@inline lidocain_1_3_inact_inib(D) = hill(D, 0.949, 284, 0.48, 0)
@inline lidocain_1_3_resting_inib(D) = hill(D, 0.997, 1462, 1.35, 0)

# From Sugimote et al. 2003
@inline NMDA_inib(D) = hill(D, 1.0, 1821, 1.3, 0)

function get_lidocaine_inhibition(C)
    if (C == 0.0)
        return 1.0, 1.0, 1.0
    end
    remaining_1_3 = 1.0 - lidocain_1_3_resting_inib(C)
    remaining_1_7 = 1.0 - lidocain_1_7_channel(C)
    remaining_1_8 = 1.0 - lidocain_1_8_channel(C)
    return remaining_1_3, remaining_1_7, remaining_1_8
end

# ----------------- Lidocaine shift inhibition trajectory ----------------- #

function add_lido_shift_inhib_traj(plt)

    lido_concentrations = 10 .^ range(log10(0.01), log10(1000), length=1000)

    results = get_lidocaine_inhibition.(lido_concentrations)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    lido_shifts_inact_1_8 = .- lido_h8.(lido_concentrations) 
    lido_shifts_act_1_8 = lido_m8.(lido_concentrations)
    lido_shifts_1_7 = .- lido_h7.(lido_concentrations)
    lido_shifts_1_3 = .- lido_h3.(lido_concentrations)
    lido_shifts_1_8 = lido_shifts_inact_1_8 .+ lido_shifts_act_1_8

    plot!(plt, 1.0 .- remaining_1_8, lido_shifts_1_8, color=:cyan, label="", linewidth = 3)

    test_point = [100.0, 1000.0, 10000.0]
    results = get_lidocaine_inhibition.(test_point)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    lido_shifts_inact_1_8 = .- lido_h8.(test_point) 
    lido_shifts_act_1_8 = lido_m8.(test_point)
    lido_shifts_1_7 = .- lido_h7.(test_point)
    lido_shifts_1_3 = .- lido_h3.(test_point)
    lido_shifts_1_8 = lido_shifts_inact_1_8 .+ lido_shifts_act_1_8

    scatter!(plt, 1.0 .- remaining_1_8, lido_shifts_1_8, color=:cyan, markersize=4, label="", markerstrokewidth = 0.0)

    return plt
end