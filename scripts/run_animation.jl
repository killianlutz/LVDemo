include("../src/modules/LVDemo.jl")
using .LVDemo
import GLMakie: with_theme, theme_dark, Theme

fig = with_theme(animate_lotka_volterra, theme_dark())