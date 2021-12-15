using Printf
using MeshRefiner

function terrain_graph()
    lat = fill(NaN, 18, 36)
    lon = copy(lat)
    elev = copy(lon)
    for i = 1:18
        for j = 1:36
            lat[i, j] = -85 + 10*(i-1)
            lon[i, j] = -175 + 10*(j-1)
            elev[i, j] = lat[i,j]/10000000
        end
    end

    t = MeshRefiner.Adaptation.TerrainMap(lat, lon, elev)
    p = MeshRefiner.Adaptation.RefinementParameters(1000, -100, 100, 0.0000000005)
    g = MeshRefiner.Adaptation.initial_graph_sphere(t)
    adapt_terrain!(g, t, p, 13)
    return t, g
end

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

t, g = terrain_graph()
export_inp(g, "spherical_map.inp")
