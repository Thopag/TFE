module TFE_package

using DifferentialEquations, Peaks, Statistics, ForwardDiff, BifurcationKit, Accessors
using Plots, Plots.Measures, LaTeXStrings, ColorSchemes, JLD2

include("ploting.jl")
include("system/model_parameters.jl")

include("system/nociceptor/simulation.jl")
include("system/projection_neuron/simulation.jl")
include("system/with_synapse/simulation.jl")

include("tools/excitability.jl")
include("tools/file_saving_parameters.jl")

include("tools/parameter_analyses.jl")
include("tools/bifurcation.jl")
include("tools/excitability_plan.jl")
include("tools/frequency_plan.jl")

# RUNS
include("run/run_simulations.jl")

include("run/run_parameter_analyses.jl")
include("run/run_bifurcation_analyses.jl")
include("run/run_excitability_plan.jl")
include("run/run_frequency_plan.jl")
include("run/run_rheobase_bar.jl")

end