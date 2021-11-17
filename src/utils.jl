"Module containing a lot of utility functions used in most other modules."
module Utils
export
    Triangle,

    center_point,
    distance,
    barycentric_matrix,
    barycentric,
    projection_area,
    approx_function,
    pyramid_function

using Colors
using Statistics
using LinearAlgebra

using ..HyperGraphs

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

function barycentric_matrix(g::HyperGraph, interior::Integer)
    v1, v2, v3 = interior_vertices(g, interior)

    barycentric_matrix(xyz(g, v1), xyz(g, v2), xyz(g, v3))
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

function barycentric(g::HyperGraph, interior::Integer, p::Array{<:Real, 1})
    M = barycentric_matrix(g, interior)
    (M*vcat(p,1))[1:2]
end

"""
    approx_function(g, interior [, val_fun])

Return approximated function over triangle.

See also: [`barycentric_matrix`](@ref), [`barycentric`](@ref)
"""
function approx_function end

function approx_function(g, interior, val_fun=(g, v)->get_prop(g, v, :value))
    M = barycentric_matrix(g, interior)
    v1, v2, v3 = interior_vertices(g, interior)
    val1, val2, val3 = map(v -> val_fun(g, v), [v1, v2, v3])
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

center_point(points::Matrix) = mean(points, dims=1)

center_point(points::Array{<:Array, 1}) = mean(points)

function center_point(g, vertices::Array)
    center_point(map(x -> xyz(g, x), vertices))
end

function center_point(g, interior::Integer)
    center_point(g, interior_vertices(g, interior))
end

"""
    distance(p1, p2)
    distance(g, v1, v2)

Return cartesian distance between points `p1` and `p2` (represented as arrays
[x, y, z]), or vertices `v1` and `v2` in graph `g`.
"""
function distance end
distance(p1::Array{<:Real, 1}, p2::Array{<:Real, 1}) = sqrt(sum(map(x -> x^2, p1-p2)))
distance(g, v1, v2) = distance(xyz(g, v1), xyz(g, v2))

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

function projection_area(g::HyperGraph, i::Integer)
    a, b, c = interior_vertices(g, i)
    projection_area(xyz(g, a), xyz(g, b), xyz(g, c))
end

end #module
