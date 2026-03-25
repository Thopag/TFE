using Revise

print("---- Start Utils ----\n")
includet("utils.jl")
using .Utils
print("---- End Utils ----\n")

print("---- Start Lidocaine effect ----\n")
includet("lidocaine.jl")
using .Lidocaine
print("---- End Lidocaine effect ----\n")

print("---- Start ODE ----\n")
includet("ODEs.jl")
using .ODE

function warm_up() 

    tspan = (0.0, 0.5)
    u0 = zeros(Float64, 14)

    p = Parameters(
        0.0, 0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0,
        0.0, 0.0, 0.0,
        false, 0.0, true,
        true, false
    )

    ODE.simulation(u0, tspan, p)

end

@time warm_up()

print("---- End ODE ----\n")

print("---- Start Ploting ----\n")
includet("ploting.jl")
using .Ploting
print("---- End Ploting ----\n")

using Plots, LaTeXStrings