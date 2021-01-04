module ProjectIO

export load_data, load_heightmap

import Images

"Load terrain data in bytes format as array of integers"
function load_data(filename)::Array{Int16, 2}
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    return reshape(nicer_data, (dim, dim))
end

"Load heighmap as array of integers"
function load_heightmap(filename, scale=255)::Array{Int16, 2}
    img = Images.load(filename)
    f(x) = Int16(trunc(Images.red(x) * scale))
    mapped = map(f, img)
    return mapped
end

end
