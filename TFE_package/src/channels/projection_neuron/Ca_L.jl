
# --------------------------- CONSTANTE Ca PARAMETER --------------------------- #

const F = 96520.0           # [C mol^-1]
const R = 8.31              # [J mol^-1 K]
const T = 309.15            # [K]
const d = 1.0               # [nm]
const tau_Ca = 10.0         # [ms]
const Ca_0  = 2.0           # [mM]
const Ca_i0 = 5e-5          # [mM]

# --------------------------- Ca_L --------------------------- #

function mL_inf(V)
    return 1.0 / ( 1.0 + exp( -(V+25.4)/6.0 ) )
end

function tau_mL(V)
    return 160.0 / ( (0.1*(-V-40.0)) / ( exp(0.1*(-V-40.0)) - 1.0 + 4.0*exp((-V-65.0)/18.0) ) )
end

function hL_inf(V)
    return 1.0 / ( 1.0 + exp( (V+14.0)/4.03 ) )
end

function tau_hL(V)
    return 10000.0
end

# ---- #

function dot_mL(V, mL)
    x_inf = mL_inf(V)
    tau_x = tau_mL(V)
    return (x_inf-mL)/tau_x
end

function dot_hL(V, hL)
    x_inf = hL_inf(V)
    tau_x = tau_hL(V)
    return (x_inf-hL)/tau_x
end

# --------------------------- [Ca] --------------------------- #

function GHK(V, Ca_i)
    w = 1e-3 * V * 2.0 * F / (R*T)
    return 1e-3 * 2.0 * F * ( Ca_i * (-w/(exp(-w)-1.0)) - Ca_0 * ( w/(exp(w)-1.0) ) )
end

function dot_Ca_i(Ca_i, ICa_L)
    return -1e7 * ( ICa_L/1e3 ) * (1.0 / (2.0*F*d) ) + (Ca_i0-Ca_i)/tau_Ca
end