using ..Utils
using ..Transformations

using LinearAlgebra
using LightGraphs, MetaGraphs

"Return relative error of approximation of traingle represented by interior `i`
to function `fun`"
function error_rel(g, fun, i)
    v1, v2, v3 = interior_vertices(g, i)

    v1coor = [x(g, v1), y(g, v1)]
    v2coor = [x(g, v2), y(g, v2)]
    v3coor = [x(g, v3), y(g, v3)]
    center = (v1coor + v2coor + v3coor) / 3.0

    a1 = get_prop(g, v1, :value)
    a2 = get_prop(g, v2, :value)
    a3 = get_prop(g, v3, :value)
    uh = (a1 + a2 + a3) / 3.0

    return (fun(center) - uh)^2 / fun(center)^2
end

"Match vertices of graph `g` to values of function `fun`. Value is set in
porperty `:value`"
function match_to_fun!(g, fun)
    for v in normal_vertices(g)
        set_prop!(g, v, :value, fun(x(g, v), y(g, v)))
    end
end

"""
    adapt_fun!(g, fun, iters)

Adapt graphs `g` to approximate function `fun`. The more iterations `iters` the
better approximation.
"""
function adapt_fun!(g, fun, iters)
    max_error = 0
    match_to_fun!(g, fun)
    for i = 1:iters
        for e in interiors(g)
            error = error_rel(g, fun, e)
            set_prop!(g, e, :error, error)
            max_error = max(max_error, error)
        end

        for e in interiors(g)
            error = get_prop(g, e, :error)
            if (error) > 0.33 * max_error
                set_prop!(g, e, :refine, true)
            end
        end

        run_transformations!(g)
        match_to_fun!(g, fun)
    end
end
