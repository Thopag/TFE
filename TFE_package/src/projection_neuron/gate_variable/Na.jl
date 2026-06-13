

function mNa_inf(V)
	vtraub = -63
	V2 = V - vtraub
	a = 0.32 * vtrap_lf(13-V2, 4)
	b = 0.28 * vtrap_lf(V2-40, 5)
	m_inf = a / (a + b)
	return m_inf
end

function tau_mNa(V)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	Vtraub = -63
	V2 = V - Vtraub
	a = 0.32 * vtrap_lf(13-V2, 4)
	b = 0.28 * vtrap_lf(V2-40, 5)
	tau_m = 1 / (a + b) / tadj
	return tau_m
end

function hNa_inf(V)
	vtraub = -63
	V2 = V - vtraub
	a = 0.128 * exp((17-V2)/18)
	b = 4 / ( 1 + exp((40-V2)/5) )
	h_inf = a / (a + b)
	return h_inf
end

function tau_hNa(V)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	Vtraub = -63
	V2 = V - Vtraub
	a = 0.128 * exp((17-V2)/18)
	b = 4 / ( 1 + exp((40-V2)/5) )
	tau_h = 1 / (a + b) / tadj
	return tau_h
end

# ---- derivative ---- #

function dot_mNa(V, mNa)
    return (mNa_inf(V)-mNa)/tau_mNa(V)
end

function dot_hNa(V, hNa)
    return (hNa_inf(V)-hNa)/tau_hNa(V)
end
