using ..Utils
using ..Transformations

using Statistics

struct BoundingBox
    min_x::Number
    max_x::Number
    min_y::Number
    max_y::Number
end


function initial_graph(terrain::TerrainMap)::AbstractMetaGraph
    g = FlatGraph()
    min_x, min_y = index_to_point(terrain, 1, 1)
    max_x, max_y = index_to_point(terrain, size(terrain.M, 1), size(terrain.M, 2))
    add_vertex!(g, [min_x, min_y], elevation_norm(terrain, min_x, min_y))
    add_vertex!(g, [min_x, max_y], elevation_norm(terrain, min_x, max_y))
    add_vertex!(g, [max_x, max_y], elevation_norm(terrain, max_x, max_y))
    add_vertex!(g, [max_x, min_y], elevation_norm(terrain, max_x, min_y))
    add_edge!(g, 1, 2, true)
    add_edge!(g, 2, 3, true)
    add_edge!(g, 3, 4, true)
    add_edge!(g, 4, 1, true)
    # diagonal
    add_edge!(g, 1, 3, false)
    add_interior!(g, 1, 2, 3, false)
    add_interior!(g, 1, 3, 4, false)
    return g
end

"""
    point_in_triangle(p, M)
    point_in_triangle(p, t)

Is point `p` inside triangle represented as:
- matrix `M`, see [`barycentric_matrix`](@ref)
- Triangle `t`, see [`Triangle`](@ref)

Note that second method is ineffective when used repeatedly on the same
triangle.
"""
function point_in_triangle end

function point_in_triangle(p, M)
    bc = barycentric(M, p)
    return bc[1] > 0 && bc[2] > 0 && 1 - bc[1] - bc[2] > 0
end

function point_in_triangle(p, t::Triangle)
    M = barycentric_matrix(t)
    point_in_triangle(p, t, M)
end

"Return all indexes of matrix (field of `terrain`) that are inside triangle `t`"
function indexes_in_triangle(t::Triangle, terrain::TerrainMap)
    t_i = map(p -> point_to_index_coords(terrain, p[1], p[2]), t)

    bb = BoundingBox(
            minimum([x(t_i[1]), x(t_i[2]), x(t_i[3])]),
            maximum([x(t_i[1]), x(t_i[2]), x(t_i[3])]),
            minimum([y(t_i[1]), y(t_i[2]), y(t_i[3])]),
            maximum([y(t_i[1]), y(t_i[2]), y(t_i[3])])
        )

    M = barycentric_matrix(t_i)
    indexes = []
    for i in ceil(Int, bb.min_x):floor(Int, bb.max_x)
        for j in ceil(Int, bb.min_y):floor(Int, bb.max_y)
            if point_in_triangle([i, j], M)
                push!(indexes, [i, j])
            end
        end
    end

    return indexes
end

"Return approximate error of traingle represented by interior `interior`."
function approx_error(g::HyperGraph, interior::Integer, terrain::TerrainMap)::Real
    v1, v2, v3 = interior_vertices(g, interior)
    triangle = (coords2D(v1), coords2D(v2), coords2D(v3))

    indexes = indexes_in_triangle(triangle, terrain)
    if isempty(indexes)
        return 0.0
    end

    points = map(i -> index_to_point(terrain, i[1], i[2]), indexes)
    M = barycentric_matrix(triangle)
    points_br = map(p -> barycentric(M, p), points)

    approx(p) = z(g, v1)*p[1] + z(g, v2)*p[2] + z(g, v3)*(1 - p[1] - p[2])
    approx_elev = map(approx, points_br)
    real_elev = map(i -> terrain.M[i[1], i[2]], indexes)

    error = sum(map(x -> x^2, approx_elev - real_elev))
    error_rel = error / sum(map(x -> x^2, real_elev))

    return error_rel
end

"Mark all traingles where error is larger than `ϵ` for refinement."
function mark_for_refinement(g::HyperGraph, terrain::TerrainMap, ϵ::Number)::Array{Number, 1}
    to_refine = []
    errors = []     # Only used for logging
    for interior in interiors(g)
        e = approx_error(g, interior, terrain)
        if e > ϵ
            set_refine!(g, interior)
            push!(to_refine, interior)
        end
        push!(errors, e)    # Only used for logging
    end

    # Only used for logging
    if !isempty(errors)
        println("Avg error: ", mean(errors))
    end
    return to_refine
end

"Adjust elevations of all vertices to fit proper values."
function adjust_elevations!(g::HyperGraph, terrain::TerrainMap)
    for v in normal_vertices(g)
        x, y = coords2D(g, v)
        elev = elevation_norm(terrain, x, y)
        set_elevation!(g, v, elev)
    end
end

"""
Scale all elevations in graph `g` to real values.

*Note* that it is called only *once* - after adaptation and graph
should *not* be adapted any further as it will not work properly.

Before calling this function all elevations are in range [0, 1].
Real life values cause overflow when calculating error for large triangles (as
it is relative error it requires division by sum of squeres of elevations).
"""
function scale_elevations!(g::HyperGraph, terrain)
    for v in normal_vertices(g)
        elev = get_elevation(g, v)
        set_elevation!(g, v, (elev - 1) * terrain.scale + terrain.offset)
    end
end

"""
    adapt_terrain!(g, terrain, ϵ, max_iters)

Adapt graph `g` to terrain map `terrain`. Stop when error is lesser than ϵ, or
after `max_iters` iterations.

See also: [`generate_terrain_mesh`](@ref)
"""
function adapt_terrain!(g::HyperGraph, terrain::TerrainMap, ϵ::Real, max_iters::Integer)
    for i in 1:max_iters
        print("Iteration ", i, ": ")
        to_refine = mark_for_refinement(g, terrain, ϵ)
        if isempty(to_refine)
            break
        end
        run_transformations!(g)
        adjust_elevations!(g, terrain)
    end
    return g
end

"""
    generate_terrain_mesh(terrain, ϵ, max_iters=20)

Generate graph (terrain mesh), based on terrain map `terrain`.

See also: [`adapt_terrain`](@ref)
"""
function generate_terrain_mesh(terrain::TerrainMap, ϵ::Real, max_iters::Integer = 20)
    g = initial_graph(terrain)
    adapt_terrain!(g, terrain, ϵ, max_iters)
    scale_elevations!(g, terrain)
    return g
end
