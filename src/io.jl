module ProjectIO

using ..Adaptation

export load_data, load_heightmap

import Images

"Load terrain data (in bytes) as TerrainMap"
function load_data(filename, dims, type=Float64)::TerrainMap
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    matrix = reshape(nicer_data, (dim, dim))
    as_floats =  map(x -> type(x), matrix)
    scale = maximum(as_flaots)
    normalized = map(x -> x / scale, as_floats)
    return TerrainMap(reversed, dims[1], dims[2], scale)
end

"Load heighmap as TerrainMap"
function load_heightmap(filename, dims, scale=255.0, type=Float64)::TerrainMap
    img = Images.load(filename)
    f(x) = type(Images.red(x))
    mapped = map(f, img)
    reversed = reverse(mapped, dims=1)
    return TerrainMap(reversed, dims[1], dims[2], scale)
end

end
