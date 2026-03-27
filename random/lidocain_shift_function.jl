

# 1.3 inactivation
function test(C)
    return   - ( (-4.8 / (1 + exp(8.56 * (log10(C) - log10(64))))) + 4.8)
end


function main()
    D = 10 .^ range(log10(0.001), log10(1000000), length=1000)

    println(test(1))
    println(test(100))
    println(test(1000))

    plt = plot(xlabel="Lidocaine (µM)", ylabel= "shift (mV)", legend=:bottomleft) 
    plot!(plt, xaxis=:log10, xlims=(0.01, 100000))

    plot!(plt, D, test.(D), label="1.8 inactivation")
    scatter!(plt, [0.01, 0.1, 100, 1000], [0.0, 0.0, -4.0, -4.8], color=:black, label="")

    display(plt)
    savefig(plt, "plots/shift.pdf")
end

main()