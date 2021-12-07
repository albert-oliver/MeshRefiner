using ..Utils
using ..Transformations

using LinearAlgebra
using Statistics

"Return relative error of approximation of traingle represented by interior `i`
to function `fun`"
function error_rel(g::HyperGraph, fun, i)
    v1, v2, v3 = interiors_vertices(g, i)
    center = mean([coords2D(g, v1), coords2D(g, v2), coords2D(g, v3)])
    uh = mean([get_value(g, v1), get_value(g, v2), get_value(g, v3)])

    return (fun(center) - uh)^2 / fun(center)^2
end

"Match vertices of graph `g` to values of function `fun`. Value is set in
porperty `:value`"
function match_to_fun!(g, fun)
    for v in normal_vertices(g)
        set_value!(g, v, fun(coords2D(g, v)))
    end
end

"""
    adapt_fun!(g, fun, iters)

Adapt graphs `g` to approximate function `fun`. The more iterations `iters` the
better approximation.
"""
function adapt_fun!(g, fun, iters)
    max_error = 0
    errors = Dict()
    match_to_fun!(g, fun)
    for i = 1:iters
        for e in interiors(g)
            error = error_rel(g, fun, e)
            errors[e] = error
            max_error = max(max_error, error)
        end

        for e in interiors(g)
            error = errors[e]
            if (error) > 0.33 * max_error
                set_refine!(g, e)
            end
        end

        refine!(g)
        match_to_fun!(g, fun)
    end
end
