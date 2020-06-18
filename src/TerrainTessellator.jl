using LightGraphs
using MetaGraphs
using Statistics
using LinearAlgebra

include("utils.jl")
include("transformations/p1.jl")
include("transformations/p2.jl")
include("transformations/p3.jl")
include("transformations/p4.jl")
include("transformations/p5.jl")
include("transformations/p6.jl")
include("transformations/p7.jl")
include("transformations/p8.jl")
include("transformations/p9.jl")
include("graphs/example_graphs.jl")
include("graphs/test_graphs.jl")

function run_for_all_triangles!(g, fun)
    executed_sth = false
    for v in nv(g):-1:1
        if get_prop(g, v, :type) == "interior"
            # executed_sth |= fun(g, v)
            ex = fun(g, v)
            if ex
                println("Executing: ", String(Symbol(fun)))
            end
            executed_sth |= ex
        end
    end
    return executed_sth
end

function run_transformations!(g)
    run_for_all_triangles!(g, transform_P1!)
    run_for_all_triangles!(g, transform_P2!)
    while true
        executed_sth = false
        executed_sth |= run_for_all_triangles!(g, transform_P3!)
        executed_sth |= run_for_all_triangles!(g, transform_P4!)
        executed_sth |= run_for_all_triangles!(g, transform_P5!)
        executed_sth |= run_for_all_triangles!(g, transform_P6!)
        executed_sth |= run_for_all_triangles!(g, transform_P7!)
        executed_sth |= run_for_all_triangles!(g, transform_P8!)
        executed_sth |= run_for_all_triangles!(g, transform_P9!)
        if !executed_sth
            return
        end
    end
end

function load_data(path::String)::AbstractMetaGraph
    map = Array{Int16, 2}[]
    g = MetaGraph()
    add_meta_vertex!(g, 1, 1, map[1, 1])
    add_meta_vertex!(g, 1, size(map, 2), map[1, size(map, 2)])
    add_meta_vertex!(g, size(map, 1), size(map, 2), map[size(map, 1), size(map, 2)])
    add_meta_vertex!(g, size(map, 1), 1, map[size(map, 1), 1])
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

const TerrainMap = Array{<:Number, 2}
const Triangle = Tuple{Array{<:Number, 1}, Array{<:Number, 1}, Array{<:Number, 1}}

struct Plane
    a::Number
    b::Number
    c::Number
    d::Number
end

function plane(p1::Array{<:Number, 1}, p2::Array{<:Number, 1}, p3::Array{<:Number, 1})::Plane
    v1 = p1 - p2
    v2 = p1 - p3
    vp = cross(v1, v2)
    a = vp[1]
    b = vp[2]
    c = vp[3]
    d = dot(v1, p3)
    return Plane(a, b, c, d)
end

z(plane::Plane, coord::Tuple{Number, Number}) = if plane.c == 0 0 else (plane.d - plane.a * coord[1] - plane.b * coord[2]) / plane.c end

function point_in_triangle(t::Triangle, coord::Tuple{Number, Number})
    x, y = coord
    x1, y1 = t[1]
    x2, y2 = t[2]
    x3, y3 = t[3]

    denominator = ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3))
    a = ((y2 - y3)*(x - x3) + (x3 - x2)*(y - y3)) / denominator
    b = ((y3 - y1)*(x - x3) + (x1 - x3)*(y - y3)) / denominator
    c = 1 - a - b;

    return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1
end

struct BoundingBox
    min_x::Number
    max_x::Number
    min_y::Number
    max_y::Number
end


function points_in_triangle(map::TerrainMap, t::Triangle)::Array{Tuple{Number, Number}, 1}
    bb = BoundingBox(minimum([t[1][1], t[2][1], t[3][1]]), maximum([t[1][1], t[2][1], t[3][1]]), minimum([t[1][2], t[2][2], t[3][2]]), maximum([t[1][2], t[2][2], t[3][2]]))

    points = Tuple{Number, Number}[]

    for i in bb.min_x:bb.max_x
        for j in bb.min_y:bb.max_y
            if point_in_triangle(t, (i, j))
                push!(points, (i, j))
            end
        end
    end

    return points
end

function approx_error(g::AbstractMetaGraph, t_map::TerrainMap, interior::Number)::Number
    triangle_points = neighbors(g, interior)
    point(g::AbstractMetaGraph, v::Number) = [x(g, v), y(g, v), z(g, v)]
    triangle = (point(g, triangle_points[1]), point(g, triangle_points[2]), point(g, triangle_points[3]))
    p = plane(triangle[1], triangle[2], triangle[3])

    points = points_in_triangle(t_map, triangle)
    square(x) = x * x
    square_diff = sum(map(coord -> square(t_map[coord[1], coord[2]] - z(p, (coord[1], coord[2]))), points))
    square_point = sum(map(coord -> square(t_map[coord[1], coord[2]]), points))

    return square_diff/square_point
end

function mark_for_refinement(g::AbstractMetaGraph, map::TerrainMap, eps::Number)::Array{Number, 1}
    get_interiors(graph) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "interior" true else false end))

    to_refine = []
    for interior in get_interiors(g)
        if approx_error(g, map, interior) > eps
            set_prop!(g, interior, :refine, true)
            push!(to_refine, interior)
        end
    end
    return to_refine
end

# g = example_graph_2()
# run_transformations!(g)
# draw_graph(g)
# draw_makie(g)
mark_for_refinement(example_graph_2(), Array{Int16}(undef, 100, 100), 0.1)
