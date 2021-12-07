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
    t = TerrainMap(elev, 200, 200, 1, 0)
    p = MeshRefiner.Adaptation.RefinementParameters(2, -5, 5, 5)
    g = MeshRefiner.generate_terrain_mesh(t, p)
end

function sin_terrain_obj()
    f = open("map_sin.obj", "w")
    for i = 1:21
        for j = 1:21
        write(f, "v $(lat[i, j]) $(lon[i,j]) $(elev[i,j])\n")
        end
   end

    for i = 1:20
        for j = 1:20
            write(f, "f $(elem[i,j]) $(elem[i+1, j]) $(elem[i+1, j+1])\n")
            write(f, "f $(elem[i,j]) $(elem[i+1, j+1]) $(elem[i, j+1])\n")
        end
    end

    close(f)
end
