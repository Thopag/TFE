using ForwardDiff, Plots

function f(x; t=1)
    return x^2 + t
end

function main()
    x = -4:0.1:4

    df(x) = ForwardDiff.derivative(a -> f(a; t=4), x)

    plt = plot(x, df.(x))
    display(plt)
end

main()