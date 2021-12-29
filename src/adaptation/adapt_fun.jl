using ..Utils
using ..Transformations

using LinearAlgebra
using Statistics

"Return relative error of approximation of traingle represented by interior `i`
to function `fun`"
function error_rel(g::HyperGraph, fun, i)
    v1, v2, v3 = interiors_vertices(g, i)
    center = mean([coords2D(g, v1), coords2D(g, v2), coords2D(g, v3)])
    uh = mean(fun.(map(x -> coords2D(g, x), [v1, v2, v3])))

    return (fun(center) - uh)^2
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
function adapt_fun!(g, fun, iters; log=true)
    for i = 1:iters
        if log
            print("Iteration $i")
        end

        max_error = 0
        errors = Dict()
        for e in interiors(g)
            error = error_rel(g, fun, e)
            errors[e] = error
            max_error = max(max_error, error)
        end

        count = 0
        for e in interiors(g)
            error = errors[e]
            if (error) > 0.33 * max_error
                set_refine!(g, e)
                count += 1
            end
        end

        if log
            println(": refined $count triangles")
        end

        refine!(g)
    end
end
