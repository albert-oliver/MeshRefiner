function terrain_graph()
    lat = fill(NaN, 17, 35)
    lon = copy(lat)
    elev = copy(lon)
    for i = 1:17
        for j = 1:35
            lat[i, j] = -80 + 10*(i-1)
            lon[i, j] = -170 + 10*(j-1)
            elev[i, j] = lat[i,j]/100
        end
    end

    t = MeshRefiner.Adaptation.TerrainMap(lat, lon, elev)
    p = MeshRefiner.Adaptation.RefinementParameters(1, -0.9, 0.9, 5)
    g = MeshRefiner.generate_terrain_mesh(t, p, 10)
    return t, g
end

t, g = terrain_graph()
