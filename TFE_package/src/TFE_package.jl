module TFE_package

using DifferentialEquations, Peaks, Statistics, ForwardDiff, BifurcationKit, Accessors
using Plots, Plots.Measures, LaTeXStrings, ColorSchemes, JLD2

include("ploting.jl")
include("utils.jl")
include("model_parameters.jl")

include("nociceptor/simulation.jl")
include("projection_neuron/simulation.jl")
include("with_synapse/simulation.jl")

include("analyses/excitability.jl")
# include("analyses/bifurcation.jl")
# include("analyses/DIC.jl")
# include("analyses/ss_currents.jl")

# precompile(simulation, (Vector{Float64}, Tuple{Float64, Float64}, ModelParameters))

# function warm_up()
#     tspan = (0.0, 0.5)
#     u0 = DIV0_u0()
#     p_noci = DIV0_parameter()
#     p_stim = stimulation_parameter(0.0; on=1.0, length=2.0)
#     p_model = model_parameter(p_stim, p_noci)
#     simulation(u0, tspan, p_model)
# end

end