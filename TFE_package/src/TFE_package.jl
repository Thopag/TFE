module TFE_package

using DifferentialEquations, Peaks, Statistics, ForwardDiff, BifurcationKit, Accessors
using Plots, Plots.Measures, LaTeXStrings, ColorSchemes, JLD2

include("ploting.jl")
include("system/model_parameters.jl")

include("system/nociceptor/simulation.jl")
include("system/projection_neuron/simulation.jl")
include("system/with_synapse/simulation.jl")
include("system/test_n1_n2/simulation.jl")

include("tools/excitability.jl")
include("tools/bifurcation.jl")
# include("analyses/DIC.jl")
# include("analyses/ss_currents.jl")

# RUNS
include("run/run_single_simulation.jl")
include("run/run_parameter_analyses.jl")
include("run/run_bifurcation_analyses.jl")

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