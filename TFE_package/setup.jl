using Revise
using Pkg

Pkg.activate("./TFE_package")

# Pkg.resolve()
# Pkg.instantiate()

using TFE_package
using Plots, LaTeXStrings, ColorSchemes, Accessors, Plots.Measures, JLD2, Logging