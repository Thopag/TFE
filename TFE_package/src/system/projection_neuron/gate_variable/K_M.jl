

function mM_inf(V)
	## Inspired from Kv7.2 Micelli #mK72inf_Micelli
    m_inf = 1 / (1 + exp((-76.1-V)/25.7))
    return m_inf
end

function tau_mM(V)
	## Inspired from Kv7.2 Micelli #taumK72_Micelli
    tau = 103 #wiegthed average
    return tau
end

# --- derivative --- #

function dot_mM(V, mM)
    return (mM_inf(V)-mM)/tau_mM(V)
end
