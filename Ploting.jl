using Plots, LaTeXStrings

function figure()

    fig1 = plot(V, S.(V), label= L"S(V)")
    plot!(V, [f_µP0.(V, 1.8) f_µP0.(V, 2.5) f_µP0.(V, 3.2)], label=[ L"µ P_{0} = 1.8" L"µ P_{0} = 2.5" L"µ P_{0} = 3.2"])

    xlims!(0, 6)
    ylims!(0, 1.5)

    xlabel!(L"V")
    ylabel!(" ")
    title!("Figure 1")

    display(fig1)
    savefig(fig1, "fig1.pdf")
end