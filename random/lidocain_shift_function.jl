

# 1.3 inactivation
function test(C)
    return  - ((-21.4 / (1 + exp(3.17 * (log10(C) - log10(120))))) + 21.4)
end


function main()
    D = 10 .^ range(log10(0.001), log10(1000000), length=1000)

    println(test(1))
    println(test(100))
    println(test(1000))

    plt = plot(xlabel="Lidocaine (µM)", ylabel= "shift (mV)", legend=:bottomleft) 
    plot!(plt, xaxis=:log10, xlims=(0.01, 100000))

    plot!(plt, D, test.(D), label="1.3 inactivation")
    scatter!(plt, [0.01001, 0.1, 1000], [0.0, 0.0, -20.3], color=:black, label="")

    display(plt)
    savefig(plt, "plots/shift.pdf")
end

main()