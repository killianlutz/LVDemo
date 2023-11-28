# jacobian vector-product
function jvp(f, x, v)
	ForwardDiff.derivative(zero(eltype(x))) do t
		f(x + t * v)
	end
end

function lv_nzfixed_point(params)
	T, α, β, γ, δ = params
	if isapprox(δ, zero(δ)) || isapprox(β, zero(β))
		fixed_point = Point2(0, 0)
	else
		fixed_point = Point2(γ/δ, α/β)
	end
	
	return fixed_point
end

# orbit examples

function lotka_volterra(z, p)
	T, α, β, γ, δ = p
	x, y = z
	
	Point2(T * x * (α - β * y), T * y * (δ * x - γ))
end

function diffeq_lotka_volterra(z, p, t)
	lotka_volterra(z, p)
end

# linearization centered around the fixed-point itself instead of zero
function linear_lv(v, params)
	fixed_point = lv_nzfixed_point(params)
	jvp(fixed_point, v - fixed_point) do z; 
		lotka_volterra(z, params); 
	end
end

function diffeq_lin_lotka_volterra(z, p, t)	
	linear_lv(z, p)
end

function lv_orbit(z0, params; kwargs...)
	prob = ODEProblem(diffeq_lotka_volterra, z0, (0, 1), params)
	solve(prob, Tsit5(); kwargs...)
end

function linear_lv_orbit(z0, params; kwargs...)
	prob = ODEProblem(diffeq_lin_lotka_volterra, z0, (0, 1), params)
	solve(prob, Tsit5(); kwargs...)
end