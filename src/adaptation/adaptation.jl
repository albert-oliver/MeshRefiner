"Most important module responsible for adaptaion of the mesh."
module Adaptation

export
    adapt_fun!,
    adapt_terrain!,
    generate_terrain_mesh,
    TerrainMap,
    elevation

"""
Struct that represents terrain map with real elevations as matrix.
"""
struct TerrainMap
    M::Array{Real, 2}
    width::Int
    height::Int
    scale::Real
    offset::Real
end

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
    x = j * terrain.width / size(terrain.M)[2] + terrain.width / (2.0 * size(terrain.M)[2])
    y = i * terrain.height / size(terrain.M)[1] + terrain.height / (2.0 * size(terrain.M)[1])
    return [x, y]
end

"Returns indexes in matrix inside terrain map `terrain` based on coodrdinates
`x`, `y`."
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
