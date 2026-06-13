
function pulse(t, ti, tf)
    return (ti <= t <= tf) ? 1.0 : 0.0
end

function spike_detection_condition(u,t,integrator)
    return u[1]  # u[1] is supposed to be V
end