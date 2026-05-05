module TFE_package

using Plots, LaTeXStrings, DifferentialEquations, Peaks, Statistics

include("utils.jl")
include("lidocaine.jl")
include("ODEs.jl")
include("ploting.jl")
include("params/DIV0.jl")
include("params/DIV7.jl")

precompile(simulation, (Vector{Float64}, Tuple{Float64, Float64}, Parameters{Float64}))

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
    simulation(u0, tspan, p)
end

end