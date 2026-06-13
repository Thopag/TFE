using Revise
using Pkg

Pkg.activate("./TFE_package")

# Pkg.resolve()
# Pkg.instantiate()

using TFE_package
const TFE = TFE_package
const ODE = TFE_package
const Ploting = TFE_package

# println("Start Warm up")
# @time TFE.warm_up()
# println("End Warm up")

using Plots, LaTeXStrings, ColorSchemes, Accessors, Plots.Measures, JLD2