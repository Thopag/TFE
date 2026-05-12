export get_lidocaine_inhibition, inact_1_3_shift, act_1_3_shift, inact_1_7_shift, act_1_7_shift, inact_1_8_shift, act_1_8_shift, lidocaine_effect_setup

# ----------------- Lidocaine shifting steady states ----------------- #


with_shift::Bool = false
with_inhibition::Bool = false

linear_mode::Bool = true

shift_inact_1p3::Float64 = 1.0

shift_inact_1p7::Float64 = 1.0

shift_inact_1p8::Float64 = 0.0
shift_act_1p8::Float64   = 0.0

function lidocaine_effect_setup()
    return "___________________________________
With inhibition : $with_inhibition
With shift : $with_shift
Linear Shift Mode : $linear_mode

1.3 inactivation : $shift_inact_1p3
1.7 inactivation : $shift_inact_1p7

1.8 inactivation : $shift_inact_1p8
1.8 activation : $shift_act_1p8
___________________________________"
end

# 1.3 inactivation
# 20 mV shift at 1000 µM (Sheets et al. 2008)
# 20.7 mV shift at 1000 µM (Lenkowski et al. 2003)
function inact_1_3_shift(C; linear_mode=linear_mode, with_shift=with_shift)
    if !with_shift
        return 0.0
    elseif linear_mode
        return -C * shift_inact_1p3
    end
    return - ((-21.4 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 21.4)
end

# 1.3 activation
function act_1_3_shift(C)
    return 0.0
end

# 1.7 inactivation
# 23 mV shift at 1000 µM (Sheets et al. 2008)
# 10.6 mV shift at 100 µM (Chevrier et al. 2004)
function inact_1_7_shift(C; linear_mode=linear_mode, with_shift=with_shift)
    if !with_shift
        return 0.0
    elseif linear_mode
        return -C * shift_inact_1p7
    end
    return - ( (-24.2 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 24.2)
end

# 1.7 activation
function act_1_7_shift(C)
    return 0.0
end

# 1.8 inactivation
# 4.8 mV shift at 1000 µM (Sheets et al. 2008)
# 4 mV shift at 100 µM (Chevrier et al. 2004)
function inact_1_8_shift(C; linear_mode=linear_mode, with_shift=with_shift)
    if !with_shift
        return 0.0
    elseif linear_mode
        return -C * shift_inact_1p8
    end
    return - ( (4.8 / (1 + exp(-14.16 * (log10(C) - log10(77))))) + 0)
end

# 1.8 activation
function act_1_8_shift(C; linear_mode=linear_mode, with_shift=with_shift)
    if !with_shift
        return 0.0
    elseif linear_mode
        return C * shift_act_1p8
    end
    return (-6.8 / (1 + exp(8.73 * (log10(C) - log10(56.5))))) + 6.8 
end

# ----------------- Lidocaine conductance inhibition ----------------- #

hill(D, f_max, IC50, h, y0) = y0 + (f_max * D^h) / (IC50^h + D^h)

# From Chevrier et al. 2004
lidocain_1_7_channel(D) = hill(D, 1.0079, 477.1, 1.31, 1.52 / 100)
lidocain_1_8_channel(D) = hill(D, 0.9698, 118.31, 1.06, 4.78 / 100)

# From Sheets et al. 2008
lidocain_1_3_inact_inib(D) = hill(D, 0.949, 284, 0.48, 0)
lidocain_1_3_resting_inib(D) = hill(D, 0.997, 1462, 1.35, 0)

function get_lidocaine_inhibition(C; with_inhibition=with_inhibition)
    # C in µM
    if (C == 0.0) || (!with_inhibition)
        return 1.0, 1.0, 1.0
    end
    remaining_1_3 = 1.0 - lidocain_1_3_resting_inib(C) # not sure about this curve context
    remaining_1_7 = 1.0 - lidocain_1_7_channel(C)
    remaining_1_8 = 1.0 - lidocain_1_8_channel(C)
    return remaining_1_3, remaining_1_7, remaining_1_8
end

# ----------------- Lidocaine shift inhibition trajectory ----------------- #

function add_lido_shift_inhib_traj(plt)

    lido_concentrations = 10 .^ range(log10(0.01), log10(1000), length=1000)

    results = get_lidocaine_inhibition.(lido_concentrations; with_inhibition=true)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    lido_shifts = .- inact_1_8_shift.(lido_concentrations; linear_mode=false, with_shift=true) .+ act_1_8_shift.(lido_concentrations; linear_mode=false, with_shift=true)

    plot!(plt, 1.0 .- remaining_1_8, lido_shifts, color=:cyan, label="Lidocaine on NaV1.8", linewidth = 3)
    # plot!(plt, 1.0 .- remaining_1_8, .- inact_1_8_shift.(lido_concentrations; linear_mode=false, with_shift=true), color=:cyan, linestyle=:dash, label="Inactivation", linewidth = 3)
    # plot!(plt, 1.0 .- remaining_1_8, .+ act_1_8_shift.(lido_concentrations; linear_mode=false, with_shift=true), color=:cyan, label="Activation", linewidth = 3)

    test_point = [100.0, 1000.0]
    results = get_lidocaine_inhibition.(test_point; with_inhibition=true)
    remaining_1_3 = [r[1] for r in results]
    remaining_1_7 = [r[2] for r in results]
    remaining_1_8 = [r[3] for r in results]

    lido_shifts = .- inact_1_8_shift.(test_point; linear_mode=false, with_shift=true) .+ act_1_8_shift.(test_point; linear_mode=false, with_shift=true)
    scatter!(plt, 1.0 .- remaining_1_8, lido_shifts, color=:cyan, markersize=4, label="", markerstrokewidth = 0.0)

    return plt
end