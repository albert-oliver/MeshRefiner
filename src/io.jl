module ProjectIO

export load_data, load_heightmap

import Images

"Load terrain data (in bytes) as matrix of floats"
function load_data(filename)::Array{Real, 2}
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    matrix = reshape(nicer_data, (dim, dim))
    return map(x -> Float16(x), matrix)
end

"Load heighmap as matrix of floats"
function load_heightmap(filename, scale=255)::Array{Real, 2}
    img = Images.load(filename)
    f(x) = Float16(Images.red(x) * scale)
    mapped = map(f, img)
    return reverse(mapped, dims=1)
end

end
