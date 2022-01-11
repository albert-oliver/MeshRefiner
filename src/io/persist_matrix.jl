function save_matrix(M, filename; next_row=1)
    open(filename, "w") do io
        write(io, "$(size(M, 1) ÷ next_row) $(size(M, 2))\n")
        for (i, row) in enumerate(eachrow(M))
            if i % next_row == 0
                join(io, string.(row), " ")
                write(io, "\n")
            end
        end
    end
end

function load_matrix(filename)
    io = open(filename, "r")
    w, h = parseInt.(split(readline(io)))
    M = zeros(w, h)
    i = 1
    for line in eachline(io)
        j = 1
        for el in parseFloat64.(split(line))
            M[i, j] = el
            j += 1
        end
        i += 1
    end
    close(io)
    M
end

parseFloat64(string) = parse(Float64, string)
parseInt(string) = parse(Int64, string)
