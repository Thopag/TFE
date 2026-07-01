
# --- mathematical functions --- #

function vtrap_lf(x,y)
	if (abs(x/y) < 1e-6)
		vtrap = y*(1 - x/y/2)
	else
		vtrap = x/(exp(x/y)-1)
	end
end

function efun(z)
	if (abs(z) < 1e-4)
		efun = 1 - z/2
	else
		efun = z/(exp(z) - 1)
	end
end

# --- calcium functions --- #

function dot_Ca_i(Ca_i, ICa_i, pn)

    ICa_i = ICa_i/1000.0  # [mA/cm^2] instead of [µA/cm^2]
    # drive_channel = - ICa_i * pn.k /(2.0*pn.F*pn.d)
    # if drive_channel <= 0.0
    #     tmp = 0.0
    # else
    #     tmp = - ICa_i * pn.k /(2.0*pn.F*pn.d) 
    # end
    return - ICa_i * pn.k /(2.0*pn.F*pn.d)  - ((Ca_i-pn.Ca_i_0)/pn.tau_Ca)
end

function ghk_LeFranc(V, ci, co) #v(mV), ci(mM), co(mM), z) 
    FARADAY = 96520 #default value ( https://www.neuron.yale.edu/neuron/static/docs/units/units.html)
    R       = 8.3134
    celsius = 36

    z = (1e-3)*2*FARADAY*V/(R*(celsius+273.15))
	eco = co*efun(z)
	eci = ci*efun(-z)
	ghk = (0.001)*2*FARADAY*(eci - eco)  

    return ghk
end

function geq_ghk_LeFranc(ci, co) #v(mV), ci(mM), co(mM), z) 
    FARADAY = 96520 #default value ( https://www.neuron.yale.edu/neuron/static/docs/units/units.html)
    R       = 8.3134
    celsius = 36

    z = (1e-3)*2*FARADAY*V/(R*(celsius+273.15))
	z/(exp(z) - 1)
	eco = co*efun(z)
	eci = ci*efun(-z)
	ghk = (.001)*2*FARADAY*(eci - eco)  

    return ghk
end
