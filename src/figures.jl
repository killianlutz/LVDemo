# animation per se
function sliders_and_spoint!(; fig=current_figure(), location=[1, 4:5])
    sg = SliderGrid(
        fig[location...],
        (label = L"T", range = 0:0.1:20.0, format = "{:.1f}", startvalue = 1.0),
        (label = L"α", range = 0:0.05:5.0, format = "{:.1f}", startvalue = 1.0),
        (label = L"β", range = 0:0.05:5.0, format = "{:.1f}", startvalue = 1.0),
        (label = L"γ", range = 0:0.05:5.0, format = "{:.1f}", startvalue = 1.0),
        (label = L"δ", range = 0:0.05:5.0, format = "{:.1f}", startvalue = 1.0),
        width = 150,
        tellheight = false
    )
    sg_vals = (; 
        T=sg.sliders[1].value,
        α=sg.sliders[2].value,
        β=sg.sliders[3].value,
        γ=sg.sliders[4].value,
        δ=sg.sliders[5].value
    )

    streamplot_axis = fig.content[1]
    Makie.deactivate_interaction!(streamplot_axis, :rectanglezoom)
    spoint = select_point(streamplot_axis.scene, marker = :diamond, color = :white)

    return (; sg_vals, spoint)
end

function liftobservables(sg_vals, spoint_initcondition)
    lv_params = lift(sg_vals...) do T, α, β, γ, δ
        (T, α, β, γ, δ)
    end
    
	saveat = range(0.0, 1.0, 300)
    orbit = lift(spoint_initcondition, lv_params) do z0, params
        lv_orbit(z0, params; saveat)
    end
    t = lift(orbit) do trajectory; trajectory.t; end
    orbit_x = lift(orbit) do trajectory; first.(trajectory.u); end
    orbit_y = lift(orbit) do trajectory; last.(trajectory.u); end
    orbit_start = lift(orbit) do trajectory; first(trajectory.u); end

	lin_orbit = lift(spoint_initcondition, lv_params) do z0, params
        linear_lv_orbit(z0, params; saveat)
    end
    lin_orbit_x = lift(lin_orbit) do trajectory; first.(trajectory.u); end
    lin_orbit_y = lift(lin_orbit) do trajectory; last.(trajectory.u); end
    
    fixed_point = lift(lv_params) do params 
        round.(lv_nzfixed_point(params), digits=2)
    end
    fixed_point_title = lift(fixed_point) do fp
        "Linearized field about $(fp)"
    end

    vector_field = lift(lv_params) do params
        z -> lotka_volterra(z, params)
    end
    lin_vector_field = lift(lv_params) do params
        z -> linear_lv(z, params)
    end

    return (; 
		orbit, t, orbit_x, orbit_y, orbit_start, 
		lin_orbit_x, lin_orbit_y, fixed_point, fixed_point_title, 
		vector_field, lin_vector_field
	)
end

function animate_lotka_volterra(xs, ys; fig_kwargs = (), axis_kwargs = (), streamplot_kwargs = ())
    fig = Figure(; fig_kwargs...)

    # l-v vector field
    axis11 = Axis(fig[1, 1]; axis_kwargs...)
    sg_vals, spoint_initcondition = sliders_and_spoint!(; fig, location=[1, 4])
    
    #### observables 
    obs = liftobservables(sg_vals, spoint_initcondition)

    streamplot!(axis11, obs.vector_field, xs, ys; streamplot_kwargs...)
    scat11 = scatter!(axis11, obs.fixed_point, color = :white, marker = :x, markersize = 15)
    scat11_orbitstart = scatter!(axis11, obs.orbit_start, color = :white, marker = :diamond, markersize = 15)
    lines11_orbit = lines!(axis11, obs.orbit_x, obs.orbit_y, color = :white, linewidth = 2)

    # linearized vector field about fixed_point
    axis12 = Axis(fig[1, 2]; axis_kwargs..., title = obs.fixed_point_title)
    axis12.ylabelvisible = false
    axis12.yticksvisible = false
    axis12.yticklabelsvisible = false

    streamplot!(axis12, obs.lin_vector_field, xs, ys; streamplot_kwargs...)
    scat12 = scatter!(axis12, obs.fixed_point, color = :white, marker = :x, markersize = 15)
    lines12_lin_orbit = lines!(axis12, obs.lin_orbit_x, obs.lin_orbit_y, color = :white, linewidth = 2)

    # example of orbit
    limits = (0.0, 1.0, 0.0, max(10.0, max(maximum(xs), maximum(ys))))
    axis13 = Axis(fig[1, 3], xlabel = L"$t$", xlabelsize = 25, limits = limits, aspect = AxisAspect(1))
    axis13.yticklabelsvisible = false

    sclx = lines!(axis13, obs.t, obs.orbit_x, linewidth = 4, color = :red)
    scly = lines!(axis13, obs.t, obs.orbit_y, linewidth = 4, color = :blue)
    linsclx = lines!(axis13, obs.t, obs.lin_orbit_x, linewidth = 3, color = :red, linestyle = :dot, alpha = 0.6)
    linscly = lines!(axis13, obs.t, obs.lin_orbit_y, linewidth = 3, color = :blue, linestyle = :dot, alpha = 0.6)

    # layout configuration
    linkaxes!(axis11, axis12)
    colgap!(fig.layout, 0)
    Legend(fig[2, 1:3], 
        [scat12, scat11_orbitstart, sclx, scly, linsclx, linscly], 
        [L"\text{Fixed point}", L"\text{Orbit start}", L"$\text{Orbit }x$", L"$\text{Orbit }y$", L"$\text{Lin. orbit }x$", L"$\text{Lin. orbit }y$"],
        orientation = :horizontal
    )

    return fig
end

function animate_lotka_volterra()
    animate_lotka_volterra(xs, ys; fig_kwargs, axis_kwargs, streamplot_kwargs)
end