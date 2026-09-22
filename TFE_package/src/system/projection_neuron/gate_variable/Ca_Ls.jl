
# --------------------------- Ca_Ls --------------------------- #

function mLs_inf(V)
	## Based on LeFrancLeMasson2010 --> m_inf =  -0.0048+(1.0257/(1+exp(-(V-(-20.4565))/4))^0.4731) #paper values
	m_inf = 1/(1+exp(-(V+25.4)/6))
	return m_inf
end

function tau_mLs(V)
    taufactor = 160
	V = V+65
	a = 1*efun(.1*(25-V))
	b = 4*exp(-V/18)
	tau_m = (taufactor/(a + b))
    return tau_m
end

function hLs_inf(V)
    zshift=0	
	zpente=0
    h_inf =   1 / (1+exp((V+(14+zshift))/(zpente+4.03)))
    return h_inf
end

function tau_hLs(V)
    tau_h =  10000
    return tau_h
end

# --- derivative --- #

function dot_mLs(V, mLs)
    return (mLs_inf(V)-mLs)/tau_mLs(V)
end

function dot_hLs(V, hLs)
    return (hLs_inf(V)-hLs)/tau_hLs(V)
end