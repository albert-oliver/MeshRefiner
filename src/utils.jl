"Module containing a lot of utility functions used in most other modules."
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
    x, y, z,
    coords,
    barycentric_matrix,
    barycentric,
    vertices_with_type,
    normal_vertices,
    hanging_nodes,
    interiors,
    is_hanging,
    is_vertex,
    is_interior,
    projection_area,
    approx_function,
    pyramid_function,
    vertex_map,
    set_values!

using Colors
using MetaGraphs
using LightGraphs
using Statistics
using LinearAlgebra

"Holds three 3-elemnt arrays [x, y, z] that represent each vertex of triangle"
const Triangle = Tuple{Array{<:Real, 1}, Array{<:Real, 1}, Array{<:Real, 1}}

"""
    barycentric_matrix(v1, v2, v3)
    barycentric_matrix(triangle)
    barycentric_matrix(g, interior)

Compute matrix that transforms cartesian coordinates to barycentric
for traingle in 2D.

In order to compute barycentric coordinates of point `p` using returned
matrix `M` use function `barycentric(M, p)`

See also [`barycentric`](@ref)
"""
function barycentric_matrix end

"Each argument is 3-element array [x,y,z] that represents coordinates traingle's
vertex"
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

    barycentric_matrix(coords(g, v1), coords(g, v2), coords(g, v3))
end

"""
    barycentric(M, p)
    barycentric(v1, v2, v3, p)
    barycentric(triangle, p)
    barycentric(g, interior, p)

Return first two coordinates of point in barcycentric coordinate system. Third
coordinate can be easily calculated: `λ₃ = 1 - λ₁ - λ₂`

Note that using this function many times on single triangle will effect in many
unnecessary computations. It is recommended to first compute matrix using
`barycentric_matrix` function, and then pass it to the method `barycentric(M, p)`.

See also: [`barycentric_matrix`](@ref)
"""
function barycentric end

function barycentric(M::Array{<:Real, 2}, p::Array{<:Real, 1})::Array{<:Real, 1}
    (M*vcat(p,1))[1:2]
end

function barycentric(v1::Array{<:Real, 1}, v2::Array{<:Real, 1} ,v3::Array{<:Real, 1}, p::Array{<:Real, 1})::Array{<:Real, 1}
    M = barycentric_matrix(v1, v2, v3)
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

"""
    approx_function(g, interior)

Return approximated function over triangle.

See also: [`barycentric_matrix`](@ref), [`barycentric`](@ref)
"""
function approx_function end

function approx_function(g, interior)
    M = barycentric_matrix(g, interior)
    v1, v2, v3 = interior_vertices(g, interior)
    val1, val2, val3 = map(v -> get_prop(g, v, :value), [v1, v2, v3])
    u(λ₁, λ₂) = val1 * λ₁ + val2 * λ₂ + val3 * (1 -  λ₁ - λ₂)
    function f(p)
        bp = barycentric(M, p)
        u(bp[1], bp[2])
    end
    f
end

"""
    pyramid_function(g, interior, summit)

Return pyramid-like function that has value 1 in `summit` vertex and 0 in
every other. It lineary decreases from 1 to 0 to neighbour vertices.

`interior` is the only triangle where this function will return proper value
"""
function pyramid_function(g, interior, summit)
    M = barycentric_matrix(g, interior)
    v1, v2, v3 = interior_vertices(g, interior)
    val1, val2, val3 = map(v -> Int(summit == v), [v1, v2, v3])
    u(λ₁, λ₂) = val1 * λ₁ + val2 * λ₂ + val3 * (1 -  λ₁ - λ₂)
    function f(p)
        bp = barycentric(M, p)
        u(bp[1], bp[2])
    end
    f
end

"""
    center_point(points)
    center_point(g, vertices)
    center_point(g, interior)

Return center of mass of delivered points, or vertices in graph

`points` is array of:
 - 3-element arrays [x, y, z], **or**
 - dictionaries with keys `:x`, `:y`, `:z`
"""
function center_point end

function center_point(points::Array{<:Dict, 1})
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

center_point(points::Array) = mean(points, dims=1)

function center_point(g, vertices::Array)
    center_point(map(x -> coords(g, x), vertices))
end

function center_point(g, interior::Integer)
    center_point(g, interior_vertices(g, interior))
end

"""
    vertices_with_type(g, type)

Return all vertices with type `type`.

See also: [`interiors`](@ref), [`hanging_nodes`](@ref),
[`normal_vertices`](@ref)
"""
function vertices_with_type(g::AbstractMetaGraph, type::String)
    filter_fun(g, v) = if get_prop(g, v, :type) == type true else false end
    filter_vertices(g, filter_fun)
end

"""
    interiors(g)

Return all vertices with type 'interior'.

See also: [`vertices_with_type`](@ref), [`hanging_nodes`](@ref),
[`normal_vertices`](@ref)
"""
function interiors(g::AbstractMetaGraph)
    vertices_with_type(g, "interior")
end

"""
    hanging_nodes(g)

Return all vertices with type 'hanging'.

See also: [`vertices_with_type`](@ref), [`interiors`](@ref),
[`normal_vertices`](@ref)
"""
function hanging_nodes(g::AbstractMetaGraph)
    vertices_with_type(g, "hanging")
end

"""
    normal_vertices(g)

Return all vertices with type 'vertex'.

See also: [`vertices_with_type`](@ref), [`hanging_nodes`](@ref),
[`hanging_nodes`](@ref)
"""
function normal_vertices(g::AbstractMetaGraph)
    vertices_with_type(g, "vertex")
end

"""
    get_hanging_node_between(g, v1, v2)

Get hanging node between normal vertices `v1` and `v2` in graph `g`.
"""
function get_hanging_node_between(g::AbstractMetaGraph, v1::Integer, v2::Integer)
    if has_edge(g, v1, v2)
        return nothing
    end
    nodes1 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v1))
    nodes2 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v2))
    nodes = intersect(nodes1, nodes2)

    x1 = get_prop(g, v1, :x)
    y1 = get_prop(g, v1, :y)
    x2 = get_prop(g, v2, :x)
    y2 = get_prop(g, v2, :y)
    for node in nodes
        xh = get_prop(g, node, :x)
        yh = get_prop(g, node, :y)
        if xh == (x1+x2)/2.0 && yh ==(y1+y2)/2.0
            return node
        end
    end

    return nothing
end

"Add vertex to graph `g` with properties `x`, `y` and `z`"
function add_meta_vertex!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "vertex")
    set_prop!(g, nv(g), :x, convert(Float64, x))
    set_prop!(g, nv(g), :y, convert(Float64, y))
    set_prop!(g, nv(g), :z, convert(Float64, z))
    return nv(g)
end

"Add hanging node to graph `g` with properties `x`, `y` and `z`"
function add_hanging!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "hanging")
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    return nv(g)
end

"Add interior to graph `g` that represents triangle `v1` `v2` `v3`.
Set `:refine` property to `boundary`."
function add_interior!(g, v1, v2, v3, refine)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, refine)
    # set_prop!(g, nv(g), :v1, v1)
    # set_prop!(g, nv(g), :v2, v2)
    # set_prop!(g, nv(g), :v3, v3)
    add_edge!(g, nv(g), v1)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), v3)
    return nv(g)
end

"Add edge to grapg `g` between vertices `v1` and `v2`. Set `:boundary` property
to `boundary`."
function add_meta_edge!(g, v1, v2, boundary)
    add_edge!(g, v1, v2)
    set_prop!(g, v1, v2, :boundary, boundary)
end

"Return vertices of triangle, that is represented by interior `i` as 3-element
Array."
function interior_vertices(g::AbstractMetaGraph, i::Integer)
    # [get_prop(g, i, :v1), get_prop(g, i, :v2), get_prop(g, i, :v3)]
    neighbors(g, i)
end

is_hanging(g, v) = get_prop(g, v, :type) == "hanging"
is_vertex(g, v) = get_prop(g, v, :type) == "vertex"
is_interior(g, v) = get_prop(g, v, :type) == "interior"

"""
    distance(p1, p2)
    distance(g, v1, v2)

Return cartesian distance between points `p1` and `p2` (represented as arrays
[x, y, z]), or vertices `v1` and `v2` in graph `g`.
"""
function distance end
distance(p1::Array{<:Real, 1}, p2::Array{<:Real, 1}) = sqrt(sum(map(x -> x^2, p1-p2)))
distance(g, v1, v2) = distance(coords(g, v1), coords(g, v2))


"""
    x(graph, vertex)
    x(point)

Returns `x` coordindate.

If `graph` and `vertex` are delivered returns `x` property of `vertex`

`point` is represented as array [x,y,z]. So returns `point[1]`. For convenience.

See also: [`y`](@ref), [`z`](@ref), [`coords`](@ref)
"""
function x end
x(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :x)
x(point::Array{<:Real, 1}) = point[1]

"""
    z(graph, vertex)
    z(point)

Returns `y` coordindate.

If `graph` and `vertex` are delivered returns `y` property of `vertex`

`point` is represented as array [x,y,z]. So returns `point[2]`. For convenience.

See also: [`x`](@ref), [`z`](@ref), [`coords`](@ref)
"""
function y end
y(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :y)
y(point::Array{<:Real, 1}) = point[2]

"""
    z(graph, vertex)
    z(point)

Returns `z` coordindate.

If `graph` and `vertex` are delivered returns `z` property of `vertex`

`point` is represented as array [x,y,z]. So returns `point[3]`. For convenience.

See also: [`x`](@ref), [`y`](@ref), [`coords`](@ref)
"""
function z end
z(graph::AbstractMetaGraph, vertex::Integer) = get_prop(graph, vertex, :z)
z(point::Array{<:Real, 1}) = point[3]

"""
    coords(g, v)

Return [x,y,z] coords of node `v` in graph `g` as 3-element Array.

See also: [`x`](@ref), [`y`](@ref), [`z`](@ref)
"""
coords(g, v) = [get_prop(g, v, :x), get_prop(g, v, :y), get_prop(g, v, :z)]

"""
    projection_area(g, i)
    projection_area(triangle)
    projection_area(a, b, c)

Calculate area of rectangular projection of triangle along z axis.
"""
function projection_area end
function projection_area(a::Array{<:Real, 1}, b::Array{<:Real, 1}, c::Array{<:Real, 1})
    ab = a[1:2] - b[1:2]
    ac = a[1:2] - c[1:2]
    abs(det(vcat(ab', ac'))) / 2
end

function projection_area(triangle::Triangle)
    a, b, c = triangle
    projection_area(a, b, c)
end

function projection_area(g::AbstractMetaGraph, i::Integer)
    a, b, c = interior_vertices(g, i)
    projection_area(coords(g, a), coords(g, b), coords(g, c))
end

"Return dictionary that maps id's of all vertices with type `vertex` to number
starting at 1."
vertex_map(g) = Dict(v => i for (i, v) in enumerate(normal_vertices(g)))

"Set `:value` property for all vertexes with type `vertex` in graph `g`. Vertex
with smalles `id` will receive value `a[1]``, next one `a[2]` and so on"
function set_values!(g, a)
    for (i, v) in enumerate(normal_vertices(g))
        set_prop!(g, v, :value, a[i])
    end
end

end
