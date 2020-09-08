function load_data(filename)::Array{Int16, 2}
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    return reshape(nicer_data, (dim, dim))
end

a = load_data("src/resources/poland1000.data")
a = map((x) -> if x < -100 x = 0 else x end, a)
println("Minimum: ", minimum(minimum.(a)))

fn = open("src/resources/poland1000_fixed.data", "w")
write(fn, convert(Array{Int16, 2}, a))
close(fn)
