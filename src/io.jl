function load_data(filename)::Array{Int16, 2}
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    return reshape(nicer_data, (dim, dim))
end
