

# 1.3 inactivation
function test_inact_1_3_shift(C)
    return   - ( (22.5 / (1 + exp(-0.015 * (C - 90)))) - 2.3)
end

# 1.3 activation
function test_act_1_3_shift(C)
    return 0
end

function main()
    D = 10 .^ range(log10(0.1), log10(10000), length=1000)

    println(test_inact_1_3_shift(1))
    println(test_inact_1_3_shift(100))
    println(test_inact_1_3_shift(1000))

    plt = plot(xlabel="Lidocaine (µM)", ylabel= "shift (mV)", legend=:bottomleft) 
    plot!(plt, xaxis=:log10, xlims=(0.1, 10000))

    plot!(plt, D, test_inact_1_3_shift.(D), label="1.3 activation")

    display(plt)
end

main()