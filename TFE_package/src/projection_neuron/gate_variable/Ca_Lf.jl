

function mLf_inf(V)
	## Based on LeFrancLeMasson2010 --> m_inf = -0.0012 + (1.0029/(1+exp((-(V+14.3907))/3.1029  #paper values without the typo (V1/2~-14, not the opposite)
	m_inf = 1/(1+exp(-(V+17.5)/4.3))
	return m_inf
end

function tau_mLf(V)
    taufactor=0.5
	V = V+65
	a = 1*efun(.1*(25-V))
	b = 4*exp(-V/18)
	tau_m = taufactor/(a + b)
    return tau_m
end

function hLf(V)
    zshift=0 
	zpente=0
    h_inf =   1 / (1+exp((V+(14+zshift))/(zpente+4.03)))
    return h_inf
end

function tau_hLf(V)
    tau_h =  1500
    return tau_h
end

# --- derivative --- #

function dot_mLf(V, mLf)
    return (mLf_inf(V)-mLf)/tau_mLf(V)
end

function dot_hLf(V, hLf)
    return (hLf_inf(V)-hLf)/tau_hLf(V)
end