using LinearAlgebra
using LightGraphs, MetaGraphs

function get_matrix(v1, v2, v3)
    vx = v2 - v1
    vy = v3 - v1
    translate = v1
    scalex = norm(vx)
    scaley = norm(vy)
    vx = normalize(vx)
    vy = normalize(vy)

    S = [
        1.0/scalex 0.0 0.0;
        0.0 1.0/scaley 0.0;
        0.0 0.0 1.0;
    ]
    R = hcat(vcat(vx, 0), vcat(vy, 0), [0,0,1])
    R = transpose(R)
    T = hcat([1,0,0], [0,1,0], vcat(-translate, 1))
    return S*R*T
end

trans_coor(v, M) = (M*vcat(v,1))[1:2]

max_from(array...) = maximum(vcat(array...))

phi1(x, y) = x
phi2(x, y) = y
phi3(x, y) = 1 - x - y

phi1(vec) = vec[1]
phi2(vec) = vec[2]
phi3(vec) = 1 - vec[1] - vec[2]

get_coor(g, v) = [get_prop(g, v, :x), get_prop(g, v, :y)]

function ortho_order(g, i)
    v1 = get_prop(g, i, :v1)
    v2 = get_prop(g, i, :v2)
    v3 = get_prop(g, i, :v3)
    v1coor = get_coor(g, v1)
    v2coor = get_coor(g, v2)
    v3coor = get_coor(g, v3)
    if dot(v2coor - v1coor, v3coor - v1coor) == 0
        return v1, v2, v3
    end
    if dot(v3coor - v2coor, v1coor - v2coor) == 0
        return v2, v1, v3
    end
    if dot(v1coor - v3coor, v2coor - v3coor) == 0
        return v3, v1, v2
    end
    return nothing
end

function error_rel(g, fun, i)
    v1, v2, v3 = ortho_order(g, i)
    # Now right angle is in vertex v1

    v1coor = [get_prop(g, v1, :x), get_prop(g, v1, :y)]
    v2coor = [get_prop(g, v2, :x), get_prop(g, v2, :y)]
    v3coor = [get_prop(g, v3, :x), get_prop(g, v3, :y)]

    # Actually I don't even need that
    M = get_matrix(v1coor, v2coor, v3coor)
    v1coor_t = trans_coor(v1coor, M)
    v2coor_t = trans_coor(v2coor, M)
    v3coor_t = trans_coor(v3coor, M)

    a1 = get_prop(g, v1, :value)
    a2 = get_prop(g, v2, :value)
    a3 = get_prop(g, v3, :value)

    center = (v1coor + v2coor + v3coor) / 3.0
    center_t = [1.0/3.0, 1.0/3.0]
#     uh = a1*phi1(center_t) + a2*phi2(center_t) + a3*phi3(center_t)
#     print(phi1(center_t), "  ", phi2(center_t), "  ", phi3(center_t))
    uh = (a1 + a2 + a3) / 3.0
    return (fun(center) - uh)^2 / fun(center)^2
end

get_vertices(g) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "vertex" true else false end))

get_interiors(g) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "interior" true else false end))

function match_to_fun!(g, fun)
    for v in get_vertices(g)
        set_prop!(g, v, :value, fun(get_prop(g, v, :x), get_prop(g, v, :y)))
    end
end

function adapt_fun!(g, fun, iters)
    max_error = 0
    match_to_fun!(g, fun)
    for i = 1:iters
        for e in get_interiors(g)
            error = error_rel(g, fun, e)
            set_prop!(g, e, :error, error)
            max_error = max(max_error, error)
        end

        for e in get_interiors(g)
            error = get_prop(g, e, :error)
            if (error) > 0.33 * max_error
                set_prop!(g, e, :refine, true)
            end
        end

        MeshRefiner.run_transformations!(g)
        match_to_fun!(g, fun)
    end
end
