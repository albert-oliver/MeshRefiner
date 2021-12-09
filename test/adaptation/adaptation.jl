using MeshRefiner.Adaptation

@testset verbose = true "Adaptation" begin

    function aux_f(x, y)
        return 2x - pi * y + sqrt(2)
    end

    function aux_f(p::AbstractVector)
        return aux_f(p[1], p[2])
    end

    function get_terrain()
        nx = 5
        ny = 5
        lat = fill(NaN, ny, nx)
        lon = copy(lat)
        elev = copy(lon)
        for i = 1:ny
            for j = 1:nx
                lat[i, j] = 3 * (i - 1)
                lon[i, j] = 2 * (j - 1)
                elev[i, j] = aux_f(lon[i, j], lat[i, j])
            end
        end
        t = TerrainMap(elev, 8, 12, 1, 0)
        t
    end

    @testset "barycentric" begin
        t = get_terrain()
        @test Adaptation.barycentric(t, [3, 4.5]) == fill(1 / 4, 4)
        @test Adaptation.barycentric(t, [2.5, 3.75]) ==
              [0.75 * 0.75, 0.75 * 0.25, 0.25 * 0.25, 0.25 * 0.75]
        @test Adaptation.barycentric(t, [3.5, 5.25]) ==
              [0.25 * 0.25, 0.25 * 0.75, 0.75 * 0.75, 0.25 * 0.75]
        @test Adaptation.barycentric(t, [3.5, 5.25]) ==
              [0.25 * 0.25, 0.25 * 0.75, 0.75 * 0.75, 0.25 * 0.75]
    end

    @testset "real_elevation" begin
        t = get_terrain()
        p = [2.6978391245, pi]

        @test Adaptation.real_elevation(t, p) ≈ aux_f(p)
        for p in eachrow(rand(20, 2))
            @test Adaptation.real_elevation(t, p * 8) ≈ aux_f(p * 8)
        end
        p = [8, 12]
        @test Adaptation.real_elevation(t, p) ≈ aux_f(p)
        p = [8, 10.5]
        @test Adaptation.real_elevation(t, p) ≈ aux_f(p)
        p = [6.23, 12]
        @test Adaptation.real_elevation(t, p) ≈ aux_f(p)
        p = [2, 3]
        @test Adaptation.real_elevation(t, p) ≈ aux_f(p)
    end

    # @test_set "point_to_index" begin
    #
    # end

end
