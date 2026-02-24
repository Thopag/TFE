using Revise

print("---- Start Utils ----\n")
includet("utils.jl")
using .Utils
print("---- End Utils ----\n")


print("---- Start DIV0 ODE ----\n")
includet("DIV0/ODEs.jl")
using .ODE_DIV0

function warm_up_DIV0()

    tspan = (0.0, 0.5)
    u0 = zeros(Float64, 14)

    p = Parameters(
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0,
        0.0, 0.0, 0.0,
        false
    )

    ODE_DIV0.simulation(u0, tspan, p)

end

@time warm_up_DIV0()

print("---- End DIV0 ODE ----\n")

print("---- Start DIV7 ODE ----\n")
includet("DIV7/ODEs.jl")
using .ODE_DIV7

function warm_up_DIV7()

    tspan = (0.0, 0.5)
    u0 = zeros(Float64, 14)

    p = Parameters(
        0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0,
        0.0, 0.0, 0.0,
        false
    )

    ODE_DIV7.simulation(u0, tspan, p)

end

@time warm_up_DIV7()

print("---- End DIV0 ODE ----\n")

print("---- Start Ploting ----\n")
includet("ploting.jl")
using .Ploting
print("---- End Ploting ----\n")

using Plots, LaTeXStrings