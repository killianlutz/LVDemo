xylims = (0.0, 6.0)
x_interval = xylims[begin]..xylims[end]
y_interval = xylims[begin]..xylims[end]
xs = range(xylims..., 50)
ys = range(xylims..., 50)

fig_kwargs = (; resolution = (1300, 450))
axis_kwargs = (; limits = (xylims..., xylims...), xticks = [xylims...], yticks = [xylims...], xlabel = L"pray $x$", ylabel = L"predator $y$", title = "Lotka-Volterra streamplot", aspect = AxisAspect(1), xlabelsize = 25, ylabelsize = 25, titlesize = 15)
streamplot_kwargs = (; colormap = :plasma)
