"Module containing a lot of utility functions used in most other modules."
module Utils
export
    Triangle,

    center_point,
    distance,
    middle_coordinates,
    barycentric_matrix,
    barycentric,
    projection_area,
    approx_function,
    pyramid_function,
    terrain_map_to_meters!,

    TerrainMap,
    real_elevation,
    index_to_point,
    point_to_index,
    point_to_index_coords,
    x_min,
    x_max,
    y_min,
    y_max,
    Δx,
    Δy,
    nx,
    ny,
    width,
    height


using Colors
using Statistics
using LinearAlgebra
using Proj4
using GeoStats

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
    v1, v2, v3 = interiors_vertices(g, interior)

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

function approx_function(g, interior, val_fun=(g, v)->get_value(g, v))
    M = barycentric_matrix(g, interior)
    v1, v2, v3 = interiors_vertices(g, interior)
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
    v1, v2, v3 = interiors_vertices(g, interior)
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
- 3-element arrays [x, y, z]
"""
function center_point end

center_point(points::Matrix) = mean(points, dims=1)

center_point(points::Array{<:Array, 1}) = mean(points)

function center_point(g, vertices::Array)
    center_point(map(x -> xyz(g, x), vertices))
end

function center_point(g, interior::Integer)
    center_point(g, interiors_vertices(g, interior))
end

"""
    distance(p1, p2)
    distance(g, v1, v2)

Return cartesian distance between points `p1` and `p2` (represented as arrays
[x, y, z]), or vertices `v1` and `v2` in graph `g`.

# Note
- When `g` is [`FlatGraph`](@ref) return distance in 2D (that is use only `x` and `y` coordinates)
- When `g` is [`SphereGraph`](@ref) use all three: `x`, `y`, `z`
"""
function distance end
distance(p1::AbstractVector{<:Real}, p2::AbstractVector{<:Real}) = norm(p1 - p2)
distance(g::FlatGraph, v1, v2) = distance(xyz(g, v1)[1:2], xyz(g, v2)[1:2])
distance(g::SphereGraph, v1, v2) = distance(xyz(g, v1), xyz(g, v2))

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
    a, b, c = interiors_vertices(g, i)
    projection_area(xyz(g, a), xyz(g, b), xyz(g, c))
end

include("terrain_map.jl")

"""
    function terrain_map_to_meters(t::TerrainMap, convert_fun)

Convert terrain map with coordinates in degrees (Geographic Coordinate System)
to maters.

`convert_fun(coords)` is a function that takes 2-element Vector of input coords
and return 2-element Vector of output coords.
"""
function terrain_map_to_meters(t::TerrainMap, convert_fun)
    trans = Proj4.Transformation("EPSG:4326", "EPSG:2180")
    new_y_min, new_x_min = trans([y_min(t), x_min(t)])
    new_y_max, new_x_max = trans([y_max(t), x_max(t)])
    new_Δy = (new_y_max - new_y_min) / (ny(t) - 1)
    new_Δx = (new_x_max - new_x_min) / (nx(t) - 1)
    TerrainMap(t.M, new_x_min, new_y_min, new_Δx, new_Δy, t.nx, t.ny)
end

"Adjust shoreline triangles, so that there is no partially submerged ones"
function adjust_shore(g)
    for interior in interiors(g)
        vs = interiors_vertices(g, interior)
        elevs = map(v -> get_elevation(g, v), vs)
        if any(elevs .> 0) && any(elevs .< 0)
            for v in vs
                if get_elevation(g, v) > 0
                    set_elevation!(g, v, 0.0)
                end
            end
        end
    end
end

"EPSG:2180 is used to convert coords from latitude, longitude (in degrees). Only
works near Europe."
function terrain_map_to_meters(t::TerrainMap)
    trans = Proj4.Transformation("EPSG:4326
    ", "EPSG:2180")
    new_t = terrain_map_to_meters(t, trans)
end

function kriging_nan(t::TerrainMap)
    indices_filled = []
    indices_nan = []
    for i in 1:size(t.M, 1)
        for j in 1:size(t.M, 2)
            if isnan(t.M[i, j])
                push!(indices_nan, [i, j])
            else
                push!(indices_filled, [i, j])
            end
        end
    end
    coords_filled = map(x -> index_to_point(t, x), indices_filled)
    coords_nan = map(x -> index_to_point(t, x), indices_nan)
    coords_nan_as_points = Point.(coords_nan)
    values_filled = map(x -> t.M[x[1], x[2]], indices_filled)
    props = (Z=values_filled,)
    𝒟 = georef(props, coords_filled)
    𝒢 = PointSet(coords_nan_as_points)
    𝒫 = EstimationProblem(𝒟, 𝒢, :Z)
    S = Kriging()
    sol = solve(𝒫, S)
    values_nan = map(x -> x[:Z], values(sol))
    M = t.M
    for ((i, j), val) in zip(indices_nan, values_nan)
        M[i, j] = val
    end
    TerrainMap(M, t.x_min, t.y_min, t.Δx, t.Δy, t.nx, t.ny)
end

end #module
