module TFE_package

using DifferentialEquations, Peaks, Statistics, ForwardDiff, BifurcationKit, Accessors
using Plots, Plots.Measures, LaTeXStrings, ColorSchemes, JLD2

include("ploting.jl")
include("utils.jl")
include("excitability.jl")
include("bifurcation.jl")
include("lidocaine.jl")
include("ODEs.jl")
include("params/DIV0.jl")
include("params/DIV7.jl")
include("DIC.jl")
include("ss_currents.jl")


precompile(simulation, (Vector{Float64}, Tuple{Float64, Float64}, Model_Parameters{Float64}))

function warm_up()
    tspan = (0.0, 0.5)
    u0 = zeros(Float64, 14)
    p = Model_Parameters(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0,
        0.0, 0.0, 0.0,
        false, 0.0
    )
    simulation(u0, tspan, p)
end

end