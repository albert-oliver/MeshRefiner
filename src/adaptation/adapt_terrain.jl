using ..Utils
using ..Transformations

using Statistics

struct TerrainMap
    M::Array{Real, 2}
    width::Int
    height::Int
end

function elevation(terrain::TerrainMap, x::Real, y::Real)
    i, j = point_to_index(terrain, x, y)
    return terrain.M[i, j]
end

function index_to_point(terrain::TerrainMap, i::Integer, j::Integer)
    i -= 1
    j -= 1
    x = j * terrain.width / size(terrain.M)[2] + terrain.width / (2.0 * size(terrain.M)[2])
    y = i * terrain.height / size(terrain.M)[1] + terrain.height / (2.0 * size(terrain.M)[1])
    return [x, y]
end

function point_to_index(terrain::TerrainMap, x::Real, y::Real)
    if x == terrain.width
        x = terrain.width - 1
    end
    if y == terrain.height
        y = terrain.height - 1
    end
    i = Int(trunc(y * size(terrain.M)[1] / terrain.height))
    j = Int(trunc(x * size(terrain.M)[2] / terrain.width))
    return [i + 1, j + 1]
end

function point_to_index_coords(terrain::TerrainMap, x::Real, y::Real)
    x_i = y * size(terrain.M)[1] / terrain.height
    y_i = x * size(terrain.M)[2] / terrain.width
    return [x_i + 1, y_i + 1]
end

struct BoundingBox
    min_x::Number
    max_x::Number
    min_y::Number
    max_y::Number
end

function initial_graph(terrain::TerrainMap)::AbstractMetaGraph
    g = MetaGraph()
    add_meta_vertex!(g, 1, 1, terrain.M[1, 1])
    add_meta_vertex!(g, 1, terrain.height, terrain.M[1, size(terrain.M, 2)])
    add_meta_vertex!(g, terrain.width, terrain.height, terrain.M[size(terrain.M, 1), size(terrain.M, 2)])
    add_meta_vertex!(g, terrain.width, 1, terrain.M[size(terrain.M, 1), 1])
    add_meta_edge!(g, 1, 2, true)
    add_meta_edge!(g, 2, 3, true)
    add_meta_edge!(g, 3, 4, true)
    add_meta_edge!(g, 4, 1, true)
    # diagonal
    add_meta_edge!(g, 1, 3, false)
    add_interior!(g, 1, 2, 3, false)
    add_interior!(g, 1, 3, 4, false)
    return g
end

function point_in_triangle(p, M)
    bc = barycentric(M, p)
    return bc[1] >= 0 && bc[2] >= 0 && 1 - bc[1] - bc[2] >= 0
end

function point_in_triangle(p, t::Triangle)
    M = barycentric_matrix(t)
    point_in_triangle(p, t, M)
end

function points_in_triangle(t::Triangle, terrain::TerrainMap)
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

function approx_in_triangle(p, M)
    v1, v2, v3 = interior_vertices(g, interior)
    br = barycentric(M, p)

    uh = *ϕ1(center_t) + a2*ϕ2(center_t) + a3*ϕ3(center_t)
end

function approx_error(g::AbstractMetaGraph, interior::Integer, terrain::TerrainMap)::Real
    v1, v2, v3 = interior_vertices(g, interior)
    triangle = ([x(v1), y(v1)], [x(v2), y(v2)], [x(v3), y(v3)])

    indexes = indexes_in_triangle(triangle, terrain)
    if isempty(indexes)
        return 0.0
    end

    points = map(i -> index_to_point(terrain, i[1], i[2]), indexes)
    M = barycentric_matrix(triangle)
    points_br = map(p -> barycentric(M, p), points)

    approx(p) = z(v1)*p[1] + z(v2)*p[2] + z(v3)*(1 - p[1] - p[2])
    approx_elev = map(approx, points_br)
    real_elev = map(i -> terrain.M[i[0], j[1]], indexes)

    error = sum(map(x -> x^2, approx_elev - real_elev))
    error_rel = error / sum(map(x -> x^2, real_elev))

    return error_rel
end

function mark_for_refinement(g::AbstractMetaGraph, terrain::TerrainMap, ϵ::Number)::Array{Number, 1}
    to_refine = []
    errors = []     # Only used for logging
    for interior in interiors(g)
        e = approx_error(g, terrain, interior)
        if e > ϵ
            set_prop!(g, interior, :refine, true)
            push!(to_refine, interior)
            push!(errors, e)    # Only used for logging
        end
    end

    # Only used for logging
    if !isempty(errors)
        println("Avg error: ", mean(errors))
    end
    return to_refine
end

function adjust_heights(g::AbstractMetaGraph, terrain::TerrainMap)
    for vertex in normal_vertices(g)
        set_prop!(g, vertex, :z, elevation(x(vertex), y(vertex)))
    end
end

function adapt_terrain!(g::AbstractMetaGraph, terrain::TerrainMap, ϵ::Real)
    i = 1
    while true
        print(i, ": ")
        to_refine = mark_for_refinement(g, terrain, ϵ)
        if isempty(to_refine)
            break
        end
        run_transformations!(g)
        adjust_heights(g, terrain)

        i += 1
    end
    return g
end

function generate_terrain_mesh(terrain::TerrainMap, ϵ::Real)
    g = initial_graph(terrain)
    return adapt_terrain!(g, terrain, ϵ)
end
