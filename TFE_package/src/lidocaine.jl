export get_lidocaine_inhibition, inact_1_3_shift, act_1_3_shift, inact_1_7_shift, act_1_7_shift, inact_1_8_shift, act_1_8_shift

# ----------------- Lidocaine shifting steady states ----------------- #

# 1.3 inactivation
function inact_1_3_shift(C)
    #return - ((-21.4 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 21.4)
    return -C * 0.0
end

# 1.3 activation
function act_1_3_shift(C)
    return 0.0
end

# 1.7 inactivation
# 23 mV shift at 1000 µM (Sheets et al. 2008)
# 10.6 mV shift at 100 µM (Chevrier et al. 2004)
function inact_1_7_shift(C)
    #return - ( (-24.2 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 24.2)
    return -C * 1.0
end

# 1.7 activation
function act_1_7_shift(C)
    return 0.0
end

# 1.8 inactivation
# 4.8 mV shift at 1000 µM (Sheets et al. 2008)
# 4 mV shift at 100 µM (Chevrier et al. 2004)
function inact_1_8_shift(C)
    #return - ( (4.8 / (1 + exp(-14.16 * (log10(C) - log10(77))))) + 0)
    return -C * 0.0
end

# 1.8 activation
function act_1_8_shift(C)
    #return (-6.8 / (1 + exp(8.73 * (log10(C) - log10(56.5))))) + 6.8
    return C * 0.0
end

# ----------------- Lidocaine conductance inhibition ----------------- #

hill(D, f_max, IC50, h, y0) = y0 + (f_max * D^h) / (IC50^h + D^h)

# From Chevrier et al. 2004
lidocain_1_7_channel(D) = hill(D, 1.0079, 477.1, 1.31, 1.52 / 100)
lidocain_1_8_channel(D) = hill(D, 0.9698, 118.31, 1.06, 4.78 / 100)

# From Sheets et al. 2008
lidocain_1_3_inact_inib(D) = hill(D, 0.949, 284, 0.48, 0)
lidocain_1_3_resting_inib(D) = hill(D, 0.997, 1462, 1.35, 0)

function get_lidocaine_inhibition(C)
    # C in µM
    if C == 0.0
        return 1.0, 1.0, 1.0
    end
    remaining_1_3 = 1.0 - lidocain_1_3_resting_inib(C) # not sure about this curve context
    remaining_1_7 = 1.0 - lidocain_1_7_channel(C)
    remaining_1_8 = 1.0 - lidocain_1_8_channel(C)
    return remaining_1_3, remaining_1_7, remaining_1_8
end
