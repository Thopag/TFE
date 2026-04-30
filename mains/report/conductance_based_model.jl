
function steady_state()

    V = -110:0.5:40

    activation(V) = 1 / (1 + exp(- (V+40)/9) )
    inactivation(V) = 1 / (1 + exp((V+65)/6) )

    xticks = []
    plt = plot(xlabel="Voltage (mV)", ylabel= "(-)", legend=:right, xticks = xticks, legendfontsize=10)

    channel_availability = (activation.(V).^3) .* inactivation.(V)
    channel_availability = channel_availability ./ maximum(channel_availability)

    plot!(plt, V, activation.(V), label="", c=:black, linestyle=:solid, linewidth = 2)
    #plot!(plt, V, inactivation.(V), label="", c=:black, linestyle=:dash, linewidth = 2)
    #plot!(plt, V, channel_availability, label="normalized channel availability", c=:black, linestyle=:dot, linewidth = 2)

    display(plt)
    savefig(plt, "plots/report/activation.pdf")
end

steady_state()