#-------------------------------------------------------------------------------
#                                 CONSTANTS
#
#-------------------------------------------------------------------------------
celsius =36
tadj = 3.0 ^ ((celsius-36)/ 10 )

zshift=0
zpente = 0
caslip = 4

#-------------------------------------------------------------------------------
#                       LEFRANC'S GATES
#
#-------------------------------------------------------------------------------
function mNa(v)
	vtraub = -63
	v2 = v - vtraub
	a = 0.32 * vtrap_lf(13-v2, 4)
	b = 0.28 * vtrap_lf(v2-40, 5)
	m_inf = a / (a + b)
	return m_inf
end
function tau_mNa(v)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	vtraub = -63
	v2 = v - vtraub
	a = 0.32 * vtrap_lf(13-v2, 4)
	b = 0.28 * vtrap_lf(v2-40, 5)
	tau_m = 1 / (a + b) / tadj

	return tau_m
end
function hNa(v)
	vtraub = -63
	v2 = v - vtraub
	a = 0.128 * exp((17-v2)/18)
	b = 4 / ( 1 + exp((40-v2)/5) )
	h_inf = a / (a + b)

	return h_inf
end
function tau_hNa(v)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	vtraub = -63
	v2 = v - vtraub
	a = 0.128 * exp((17-v2)/18)
	b = 4 / ( 1 + exp((40-v2)/5) )
	tau_h = 1 / (a + b) / tadj
	
	return tau_h
end
function mKDR(v)
	vtraub = -63
	v2 = v - vtraub

	a = 0.032 * vtrap_lf(15-v2, 5)
	b = 0.5 * exp((10-v2)/40)
	n_inf = a / (a + b)

	return n_inf
end
function tau_mKDR(v)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	vtraub = -63
	v2 = v - vtraub

	a = 0.032 * vtrap_lf(15-v2, 5)
	b = 0.5 * exp((10-v2)/40)
	tau_n = 1 / (a + b) / tadj

	return tau_n
end
function vtrap_lf(x,y)
	if (abs(x/y) < 1e-6)
		vtrap = y*(1 - x/y/2)
	else
		vtrap = x/(exp(x/y)-1)
	end
end


function mKir(v)
	vhalf=-65 #(mV)
	zslope=10 #(mV)
	m_inf = 1/(1+ exp((v-vhalf)/zslope))
	return m_inf
end
function tau_mKir(v)
	tau_kir=1 #(ms)
	tau_m = tau_kir
    return tau_m
end


function mCaLf(v)
	## Based on LeFrancLeMasson2010 --> m_inf = -0.0012 + (1.0029/(1+exp((-(v+14.3907))/3.1029  #paper values without the typo (V1/2~-14, not the opposite)
	m_inf = 1/(1+exp(-(v+17.5)/4.3))
	return m_inf
end
function tau_mCaLf(v)
    taufactor=0.5
	v = v+65
	a = 1*efun(.1*(25-v))
	b = 4*exp(-v/18)
	tau_m = taufactor/(a + b)
    return tau_m
end
function hCaLf(v)
    zshift=0 
	zpente=0
    h_inf =   1 / (1+exp((v+(14+zshift))/(zpente+4.03)))
    return h_inf
end
function tau_hCaLf(v)
    tau_h =  1500
    return tau_h
end


function mCaLs(v)
	## Based on LeFrancLeMasson2010 --> m_inf =  -0.0048+(1.0257/(1+exp(-(v-(-20.4565))/4))^0.4731) #paper values
	m_inf = 1/(1+exp(-(v+25.4)/6))
	return m_inf
end
function tau_mCaLs(v)
    taufactor = 160
	v = v+65
	a = 1*efun(.1*(25-v))
	b = 4*exp(-v/18)
	tau_m = (taufactor/(a + b))
    return tau_m
end
function hCaLs(v)
    zshift=0	
	zpente=0
    h_inf =   1 / (1+exp((v+(14+zshift))/(zpente+4.03)))
    return h_inf
end
function tau_hCaLs(v)
    tau_h =  10000
    return tau_h
end

function efun(z)
	if (abs(z) < 1e-4)
		efun = 1 - z/2
	else
		efun = z/(exp(z) - 1)
	end
end



#-------------------------------------------------------------------------------
#                     LEFRANC'S CALCIUM DEPEDENT GATES
#
#-------------------------------------------------------------------------------
function m_carac_ican_lf(cai)
	cac_ican = 0.9
	beta = 0.002

	alpha2 = beta * (cai/cac_ican)^2

    m_inf = alpha2 / ( alpha2 + beta )
    tau_m =  1000 #value from .ses file

	return tau_m,m_inf
end
function o_carac_isk(cai)
	k = 0.05

    o_inf = cai / ( cai + k )
    tau_o = 10

	return tau_o,o_inf
end

#-------------------------------------------------------------------------------
#                                  KM GATE
#
#-------------------------------------------------------------------------------
function mKM(v)
	## Inspired from Kv7.2 Micelli #mK72inf_Micelli
    m_inf = 1 ./ (1 .+ exp.((-76.1-v)./25.7))
    return m_inf
end
function tau_mKM(v)
	## Inspired from Kv7.2 Micelli #taumK72_Micelli
    tau = 103 #wiegthed average
    return tau
end

#-------------------------------------------------------------------------------
#                     LEFRANC'S GHK
#
#-------------------------------------------------------------------------------
function ghk_LeFranc( V, ci, co) #v(mV), ci(mM), co(mM), z) 
    FARADAY = 96520 #default value ( https://www.neuron.yale.edu/neuron/static/docs/units/units.html)
    R       = 8.3134
    celsius = 36

    z = (1e-3)*2*FARADAY*V/(R*(celsius+273.15))
	eco = co*efun(z)
	eci = ci*efun(-z)
	ghk = (.001)*2*FARADAY*(eci - eco)  

    return ghk
end
function geq_ghk_LeFranc( ci, co) #v(mV), ci(mM), co(mM), z) 
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


# ------------------------ Synaptic GATES ------------------------

        function NMDA_Mg_block(v) 
            mgo = 1.0 #[mM]

            m = 1 / (1 + exp(0.062 * -v) * (mgo / 3.57 ))
            return m
        end
