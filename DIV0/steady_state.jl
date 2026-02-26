
f = ODE_DIV0.alpha_h_1_3
norm = 1 #maximum((f(-10000), f(10000)))

V = -70:0.5:60

plt = plot(xlabel="Voltage (mV)", ylabel= "- (-)")
plot!(plt, V, f.(V) ./ norm, color= :black)
display(plt)
