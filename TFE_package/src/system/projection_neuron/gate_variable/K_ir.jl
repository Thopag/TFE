
# --------------------------- K_ir --------------------------- #

function mir_inf(V)
	vhalf=-65 #(mV)
	zslope=10 #(mV)
	m_inf = 1/(1+ exp((V-vhalf)/zslope))
	return m_inf
end

function tau_mir(V)
	tau_kir=1 #(ms)
	tau_m = tau_kir
    return tau_m
end

# --- derivative --- #

function dot_mir(V, mir)
    return (mir_inf(V)-mir)/tau_mir(V)
end
