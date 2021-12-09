"Most important module responsible for adaptaion of the mesh."
module Adaptation

using ..HyperGraphs
using ..Utils
using ..Transformations

import ..Utils: barycentric

export
adapt_fun!,
adapt_terrain!,
generate_terrain_mesh,
TerrainMap,
elevation,
match_to_fun!,
check_mesh

"""
Struct that represents terrain map with real elevations as matrix.
"""
struct TerrainMap
    M::Array{Real, 2}
    width::Real
    height::Real
    scale::Real
    offset::Real
end

"Return barycentric coordinates of point `p` in the single cell of
terrain map `t`"
function barycentric(t::TerrainMap, p::AbstractVector)

    # Translated p is the point with origin in the bottom/left corner of the cell (not the map)
    i, j = point_to_index(t, p)
    translated_p = p - index_to_point(t, i, j)

    delta_x_left = translated_p[1] / delta_x(t)
    delta_y_bottom = translated_p[2] / delta_y(t)
    delta_x_right = 1 - delta_x_left
    delta_y_top = 1 - delta_y_bottom

    return [
        delta_x_right * delta_y_top,
        delta_x_left * delta_y_top,
        delta_x_left * delta_y_bottom,
        delta_x_right * delta_y_bottom
    ]
end

function delta_x(t)
    return t.width/(size(t.M, 2) - 1)
end

function delta_y(t)
    return t.height/(size(t.M, 1) - 1)
end


function real_elevation(t::TerrainMap, p::AbstractVector)
    bc = barycentric(t, p)
    i, j = point_to_index(t, p)
    heights = [
        t.M[i, j],
        t.M[i, j+1],
        t.M[i+1, j+1],
        t.M[i+1, j]
    ]
    return dot(heights, bc)
end

real_elevation(t::TerrainMap, x, y) = real_elevation(t, [x, y])

"Return elevation normalized to range [1.0, 2.0] at point (`x`, 'y')."
function elevation_norm(terrain::TerrainMap, x::Real, y::Real)
    i, j = point_to_index(terrain, x, y)
    return terrain.M[i, j]
end

"Return elevation at point (`x`, 'y')."
function elevation(terrain::TerrainMap, x::Real, y::Real)
    return (elevation_norm(terrain, x, y) - 1) * terrain.scale + terrain.offset
end

"Returns coodrinates of point based on it's indexes in matrix inside terrain
map `terrain`."
function index_to_point(terrain::TerrainMap, i::Integer, j::Integer)
    i -= 1
    j -= 1
    x = j * delta_x(terrain) # terrain.width / size(terrain.M)[2] + terrain.width / (2.0 * size(terrain.M)[2])
    y = i * delta_y(terrain) # terrain.height / size(terrain.M)[1] + terrain.height / (2.0 * size(terrain.M)[1])
    return [x, y]
end

"Returns the lowest-left indexes in matrix inside terrain map `terrain` based on
coodrdinates `x`, `y`."
function point_to_index(terrain::TerrainMap, x::Real, y::Real)
    if x == terrain.width
        x = terrain.width - 1
    end
    if y == terrain.height
        y = terrain.height - 1
    end
    i = Int(trunc(y / delta_y(terrain)))
    j = Int(trunc(x / delta_x(terrain)))

    i = i + 1
    j = j + 1

    if i > size(terrain.M, 1) || i < 1
        throw(DomainError("Point not in terrain map"))
    end

    if j > size(terrain.M, 2) || j < 1
        throw(DomainError("Point not in terrain map"))
    end

    if i == size(terrain.M, 1)
        i = i - 1
    end

    if j == size(terrain.M, 2)
        j = j - 1
    end

    return [i, j]
end

point_to_index(t::TerrainMap, p::AbstractVector) = point_to_index(t, p[1], p[2])

"""
point_to_index_coords(terrain, x, y)

Similar to `point_to_index` but doesn't result to integers. So you could say
that returned values are coordinates in 'matrix based system'.

For example, when `point_to_index_coords` return `[1.2, 5.8]`, then
`point_to_index` would return [1, 6] (rounded result), so it can be used as
indexes in matrix.

See also: [`point_to_index`](@ref), [`index_to_point`](@ref)
"""
function point_to_index_coords(terrain::TerrainMap, x::Real, y::Real)
    if x == terrain.width
        x = terrain.width - 1
    end
    if y == terrain.height
        y = terrain.height - 1
    end
    x_i = y * size(terrain.M)[1] / terrain.height
    y_i = x * size(terrain.M)[2] / terrain.width
    return [x_i + 1, y_i + 1]
end

include("adapt_fun.jl")
include("adapt_terrain.jl")

end
