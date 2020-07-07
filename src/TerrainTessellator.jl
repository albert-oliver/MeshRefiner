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
include("io.jl")

const TerrainMap = Array{<:Number, 2}
const Triangle = Tuple{Array{<:Number, 1}, Array{<:Number, 1}, Array{<:Number, 1}}

function run_for_all_triangles!(g, fun)
    get_interiors(graph) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "interior" true else false end))

    ran = false
    for v in get_interiors(g)
        ex = fun(g, v)
        # if ex
        #     println("Executed: ", String(Symbol(fun)))
        # end
        ran |= ex
    end
    return ran
end

function run_transformations!(g)
    run_for_all_triangles!(g, transform_P1!)
    run_for_all_triangles!(g, transform_P2!)

    while true
        ran = false
        ran |= run_for_all_triangles!(g, transform_P3!)
        ran |= run_for_all_triangles!(g, transform_P4!)
        ran |= run_for_all_triangles!(g, transform_P5!)
        ran |= run_for_all_triangles!(g, transform_P6!)
        ran |= run_for_all_triangles!(g, transform_P7!)
        ran |= run_for_all_triangles!(g, transform_P8!)
        ran |= run_for_all_triangles!(g, transform_P9!)
        if !ran
            return false
        end
    end
end

function initial_graph(map::TerrainMap)::AbstractMetaGraph
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

struct Plane
    a::Float64
    b::Float64
    c::Float64
    d::Float64
end

function plane(p1::Array{<:Number, 1}, p2::Array{<:Number, 1}, p3::Array{<:Number, 1})::Plane
    v1 = p1 - p2
    v2 = p1 - p3
    vp = cross(v1, v2)
    a = vp[1]
    b = vp[2]
    c = vp[3]
    d = dot(vp, p1)
    return Plane(a, b, c, d)
end

z(plane::Plane, coord::Tuple{Number, Number})::Float64 = if plane.c == 0 0 else (plane.d - plane.a * coord[1] - plane.b * coord[2]) / plane.c end

function point_in_triangle(t::Triangle, coord::Tuple{Number, Number})
    x, y = coord
    x1, y1 = t[1]
    x2, y2 = t[2]
    x3, y3 = t[3]

    p1 = [x1-x, y1-y, 0]
    p2 = [x2-x, y2-y, 0]
    p3 = [x3-x, y3-y, 0]

    x12 = [x2-x1, y2-y1, 0]
    x23 = [x3-x2, y3-y2, 0]
    x31 = [x1-x3, y1-y3, 0]

    a = cross(p1, x12)
    b = cross(p2, x23)
    c = cross(p3, x31)

    return (a[3] > 0 && b[3] > 0 && c[3] > 0) || (a[3] < 0 && b[3] < 0 && c[3] < 0)
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

    for i in ceil(Int, bb.min_x):floor(Int, bb.max_x)
        for j in ceil(Int, bb.min_y):floor(Int, bb.max_y)
            if point_in_triangle(t, (i, j))
                push!(points, (i, j))
            end
        end
    end

    return points
end

function approx_error(g::AbstractMetaGraph, t_map::TerrainMap, interior::Number)::Number
    triangle_points = interior_vertices(g, interior)
    point(g::AbstractMetaGraph, v::Number) = [x(g, v), y(g, v), z(g, v)]
    triangle = (point(g, triangle_points[1]), point(g, triangle_points[2]), point(g, triangle_points[3]))
    p = plane(triangle[1], triangle[2], triangle[3])

    points = points_in_triangle(t_map, triangle)
    square(x) = x * x
    if isempty(points)
        return 0.0
    end

    return sum(map(coord -> abs(convert(Int128, t_map[coord[1], coord[2]]) - round(Int128, z(p, (coord[1], coord[2])))), points))
end

function mark_for_refinement(g::AbstractMetaGraph, map::TerrainMap, eps::Number)::Array{Number, 1}
    get_interiors(graph) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "interior" true else false end))

    to_refine = []
    errors = []
    for interior in get_interiors(g)
        e = approx_error(g, map, interior)
        # println("Error: ", e)
        if e > eps
            # println("To refine: ", interior)
            set_prop!(g, interior, :refine, true)
            push!(to_refine, interior)
            push!(errors, e)
        end
    end
    if !isempty(errors)
        println("Avg error: ", mean(errors))
    end
    return to_refine
end

function adjust_heights(g::AbstractMetaGraph, map::TerrainMap)
    get_vertices(graph) = filter_vertices(g, (g, v) -> (if get_prop(g, v, :type) == "vertex" true else false end))

    for vertex in get_vertices(g)
        set_prop!(g, vertex, :z, map[round(Int, x(g, vertex)), round(Int, y(g, vertex))])
    end
end


t_map = load_data("src/resources/poland500.data")
g = initial_graph(t_map)

accuracy = 100

for i in 1:18
    print(i, ": ")
# while true
    to_refine = mark_for_refinement(g, t_map, accuracy)
    if isempty(to_refine)
        return
    end
    run_transformations!(g)
    adjust_heights(g, t_map)
end


draw_makie(g)
