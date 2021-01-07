module Utils
export
    Triangle,

    center_point,
    get_hanging_node_between,
    add_meta_vertex!,
    add_hanging!,
    add_interior!,
    interior_vertices,
    add_meta_edge!,
    distance,
    cartesian_distance,
    x, y, z, funny,
    coords,
    barycentric_matrix,
    barycentric,
    vertices_with_type,
    normal_vertices,
    hanging_nodes,
    interiors

using Colors
using MetaGraphs
using LightGraphs

const Triangle = Tuple{Array{<:Real, 1}, Array{<:Real, 1}, Array{<:Real, 1}}

"""
    barycentric_matrix(v1, v2, v3)

Compute matrix that transforms cartesian coordinates to barycentric
for trainglen in 2D.

In order to compute barycentric coordinates of point `p` using returned
matrix `M` use function `barycentric(M, p)``
"""
function barycentric_matrix end

function barycentric_matrix(v1::Array{<:Real, 1}, v2::Array{<:Real, 1}, v3::Array{<:Real, 1})
    x1, y1 = v1[1:2]
    x2, y2 = v2[1:2]
    x3, y3 = v3[1:2]
    M = [
        x1 x2 x3;
        y1 y2 y3;
        1  1  1
    ]
    return inv(M)
end

function barycentric_matrix(triangle::Triangle)
    barycentric_matrix(triangle[1], triangle[2], triangle[3])
end

function barycentric_matrix(g::AbstractMetaGraph, interior::Integer)
    v1, v2, v3 = interior_vertices(g, interior)

    barycentric_matrix(coords(v1), coords(v2), coords(v3))
end

function barycentric(M::Array{<:Real, 2}, p::Array{<:Real, 1})::Array{<:Real, 1}
    (M*vcat(p,1))[1:2]
end

function barycentric(triangle::Triangle, p::Array{<:Real, 1})::Array{<:Real, 1}
    M = barycentric_matrix(triangle)
    (M*vcat(p,1))[1:2]
end

function barycentric(g::AbstractMetaGraph, interior::Integer, p::Array{<:Real, 1})
    M = barycentric_matrix(g, interior)
    (M*vcat(p,1))[1:2]
end

function center_point(points::Array{Dict, 1})
    mean = [0.0, 0.0, 0.0]
    for point in points
        mean[1] += point[:x]
        mean[2] += point[:y]
        mean[3] += point[:z]
    end
    mean[1] /= size(points, 1)
    mean[2] /= size(points, 1)
    mean[3] /= size(points, 1)
    return mean
end

center_point(points::Array{Array{<:Real, 1}, 1}) = mean(points)

function center_point(g, points::Array{Array{<:Integer, 1}, 1})
    center_point(map(x -> coords(g, x), points))
end

function vertices_with_type(g::AbstractMetaGraph, type::String)
    filter_fun(g, v) = if get_prop(g, v, :type) == type true else false end
    filter_vertices(g, filter_fun)
end

function interiors(g::AbstractMetaGraph)
    vertices_with_type(g, "interior")
end

function hanging_nodes(g::AbstractMetaGraph)
    vertices_with_type(g, "hanging")
end

function normal_vertices(g::AbstractMetaGraph)
    vertices_with_type(g, "vertex")
end

function get_hanging_node_between(g::AbstractMetaGraph, v1::Integer, v2::Integer)
    if has_edge(g, v1, v2)
        return nothing
    end
    nodes1 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v1))
    nodes2 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v2))
    nodes = intersect(nodes1, nodes2)

    for node in nodes
        x1 = get_prop(g, v1, :x)
        y1 = get_prop(g, v1, :y)
        x2 = get_prop(g, v2, :x)
        y2 = get_prop(g, v2, :y)
        xh = get_prop(g, node, :x)
        yh = get_prop(g, node, :y)
        if xh == (x1+x2)/2.0 && yh ==(y1+y2)/2.0
            return node
        end
    end

    return nothing
end

function add_meta_vertex!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "vertex")
    set_prop!(g, nv(g), :x, convert(Float64, x))
    set_prop!(g, nv(g), :y, convert(Float64, y))
    set_prop!(g, nv(g), :z, convert(Float64, z))
    return nv(g)
end

function add_hanging!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "hanging")
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    return nv(g)
end

function add_interior!(g, v1, v2, v3, refine)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, refine)
    set_prop!(g, nv(g), :v1, v1)
    set_prop!(g, nv(g), :v2, v2)
    set_prop!(g, nv(g), :v3, v3)
    return nv(g)
end

function add_meta_edge!(g, v1, v2, boundary)
    add_edge!(g, v1, v2)
    set_prop!(g, v1, v2, :boundary, boundary)
end

function interior_vertices(g::AbstractMetaGraph, i::Integer)
    [get_prop(g, i, :v1), get_prop(g, i, :v2), get_prop(g, i, :v3)]
end

distance(p1::Array{<:Real, 1}, p2::Array{<:Real, 1}) = sqrt(sum(map(x -> x^2, p1-p2)))

distance(g, v1, v2) = distance(coords(g, v1), coords(g, v2))

# distance(graph::AbstractMetaGraph, vertex_1::Integer, vertex_2::Integer) = cartesian_distance(props(graph, vertex_1), props(graph, vertex_2))

function cartesian_distance(p1, p2)
    x1 = convert(Float64, p1[:x])
    x2 = convert(Float64, p2[:x])
    y1 = convert(Float64, p1[:y])
    y2 = convert(Float64, p2[:y])

    return sqrt(sum([(x1-x2)^2, (y1-y2)^2]))
end

x(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :x)
x(p::Array{<:Real, 1}) = p[1]
y(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :y)
y(p::Array{<:Real, 1}) = p[2]
z(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :z)
z(p::Array{<:Real, 1}) = p[3]
coords(g, v) = [get_prop(g, v, :x), get_prop(g, v, :y), get_prop(g, v, :z)]
funny = z

end
