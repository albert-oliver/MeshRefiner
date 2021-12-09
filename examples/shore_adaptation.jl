include("../src/MeshRefiner")

function sin_terrain_graph()
    lat = fill(NaN, 21, 21)
    lon = copy(lat)
    elev = copy(lon)
    for i = 1:21
        for j = 1:21
            lat[i, j] = -100 + 10*(i-1)
            lon[i, j] = -100 + 10*(j-1)
            elev[i, j] = 50*sin(lat[i,j]*pi/200)
        end
    end

    t = MeshRefiner.Adaptation.TerrainMap(elev, 200, 200, 1, 0)
    p = MeshRefiner.Adaptation.RefinementParameters(0.1, -5, 5, 1)
    g = MeshRefiner.generate_terrain_mesh(t, p)
    return t, g
end

function sin_terrain_obj()

    t, g = sin_terrain_graph()
    x = fill(NaN, size(t.M))
    y = fill(NaN, size(t.M))

    for i = 1:size(t.M, 1)
        for j = 1:size(t.M, 2)
            x[i, j], y[i, j] = MeshRefiner.Adaptation.index_to_point(t, i, j)
        end
    end

    f = open("map_sin.inp", "w")
    write(f, " $(length(x)) $((size(t.M, 1)-1)*(size(t.M, 2)-1)) 0 0 0\n")

    elem = Matrix{Int}(undef, size(x))

    for i = 1:size(x, 1)
        for j = 1:size(x, 2)
            idx = j+((i-1)*size(x,2))
            elem[i, j] = idx
            write(f, "$(idx) $(x[i, j]) $(y[i,j]) $(elev[i,j])\n")
        end
    end

    for i = 1:(size(x, 1) - 1)
        for j = 1:(size(x, 2) - 1)
            write(f, "$(j+((i-1)*(size(x,2)-1))) 0 quad $(elem[i,j]) $(elem[i, j+1]) $(elem[i+1, j+1]) $(elem[i+1, j])\n")
        end
    end

    close(f)

    export_inp(g, "sin_mesh.inp")

end
using Printf


function export_inp(g, filename)
    open(filename, "w") do io
        v_id = 1
        t_map = Dict()
        fun_map = Dict()
        counter = 0
        list_nv = collect(MeshRefiner.HyperGraphs.normal_vertices(g))
        list_hv = collect(MeshRefiner.HyperGraphs.hanging_nodes(g))
        list_interiors = collect(MeshRefiner.HyperGraphs.interiors(g))
        write(io, @sprintf("%d %d 0 0 0\n", length(list_nv) + length(list_hv), length(list_interiors)))
        for v in list_nv
            x, y, z = MeshRefiner.HyperGraphs.xyz(g, v)
            counter = counter + 1
            write(io, @sprintf("%d %f %f %f\n", counter, x, y, z))
            t_map[v] = v_id
            v_id += 1
        end

        # TODO remove
        for v in list_hv
            x, y, z = MeshRefiner.HyperGraphs.xyz(g, v)
            counter = counter + 1
            write(io, @sprintf("%d %f %f %f\n", counter, x, y, z))
            t_map[v] = v_id
            v_id += 1
        end

        counter = 0

        for i in list_interiors
            v1, v2, v3 = MeshRefiner.HyperGraphs.interiors_vertices(g, i)
            counter = counter + 1
            write(io, @sprintf("%d 0 tri %d %d %d\n", counter, t_map[v1], t_map[v2], t_map[v3]))
        end
    end
end
