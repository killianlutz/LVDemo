module LVDemo

using GLMakie
using ForwardDiff
using DifferentialEquations

include("../fig_parameters.jl")
include("../ode_solves.jl")
include("../figures.jl")

export animate_lotka_volterra

end # module LVDemo