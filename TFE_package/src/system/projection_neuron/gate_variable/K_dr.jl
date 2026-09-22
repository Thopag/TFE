
# --------------------------- K_dr --------------------------- #

function mdr_inf(V)
	Vtraub = -63
	V2 = V - Vtraub

	a = 0.032 * vtrap_lf(15-V2, 5)
	b = 0.5 * exp((10-V2)/40)
	n_inf = a / (a + b)

	return n_inf
end

function tau_mdr(V)
	celsius =36
	tadj = 3.0 ^ ((celsius-36)/ 10 )
	vtraub = -63
	V2 = V - vtraub

	a = 0.032 * vtrap_lf(15-V2, 5)
	b = 0.5 * exp((10-V2)/40)
	tau_n = 1 / (a + b) / tadj
	return tau_n
end

# --- derivative --- #

function dot_mdr(V, mdr)
    return (mdr_inf(V)-mdr)/tau_mdr(V)
end
