module Adaptation

export
    adapt_fun!,
    adapt_terrain!,
    generate_terrain_mesh,
    TerrainMap,
    elevation

    struct TerrainMap
        M::Array{Real, 2}
        width::Int
        height::Int
        scale::Real
        offset::Real
    end

    function elevation_norm(terrain::TerrainMap, x::Real, y::Real)
        i, j = point_to_index(terrain, x, y)
        return terrain.M[i, j]
    end

    function elevation(terrain::TerrainMap, x::Real, y::Real)
        return (elevation_norm(terrain, x, y) - 1) * terrain.scale + terrain.offset
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
