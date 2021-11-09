using MeshRefiner.HyperGraphs

import Graphs; const Gr = Graphs
import MetaGraphs; const MT = MetaGraphs

@testset "SphereGraph" begin
    g = SphereGraph(100)
    @test g.vertices_count == 0
    @test g.interior_count == 0
    @test g.hanging_count == 0
    @test g.radius == 100
    @test Gr.nv(g.graph) == 0
    @test Gr.ne(g.graph) == 0

    g = SphereGraph()
    @test g.vertices_count == 0
    @test g.interior_count == 0
    @test g.hanging_count == 0
    @test Gr.nv(g.graph) == 0
    @test Gr.ne(g.graph) == 0
end

@testset verbose = true "add_vertex!" begin
    @testset "Basic" begin
        @testset "Single vertex" begin
            g = SphereGraph(100)
            add_vertex!(g, [1, 2, 2])
            @test g.vertices_count == 1
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 1
            @test Gr.ne(g.graph) == 0

            g = SphereGraph(100)
            add_vertex!(g, [3, 5], 10)
            @test g.vertices_count == 1
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 1
            @test Gr.ne(g.graph) == 0

            g = SphereGraph(100)
            add_vertex!(g, [1, 2, 3]; value = 10)
            @test g.vertices_count == 1
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 1
            @test Gr.ne(g.graph) == 0

            g = SphereGraph(100)
            add_vertex!(g, [1, 2], 10; value = 10)
            @test g.vertices_count == 1
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 1
            @test Gr.ne(g.graph) == 0
        end

        @testset "Multiple vertices" begin
            g = SphereGraph(100)
            add_vertex!(g, [1, 2, 2])
            @test g.vertices_count == 1
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 1
            @test Gr.ne(g.graph) == 0

            add_vertex!(g, [1, 3, 5])
            @test g.vertices_count == 2
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 2
            @test Gr.ne(g.graph) == 0

            add_vertex!(g, [0, 1, 0])
            @test g.vertices_count == 3
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 3
            @test Gr.ne(g.graph) == 0

            add_vertex!(g, [4, 6, 1])
            @test g.vertices_count == 4
            @test g.interior_count == 0
            @test g.hanging_count == 0
            @test g.radius == 100
            @test Gr.nv(g.graph) == 4
            @test Gr.ne(g.graph) == 0
        end
    end

    @testset "Cartesian to spherical" begin
        @testset "Cartesian" begin
            g = SphereGraph()
            add_vertex!(g, [1, 2, 3])
            @test xyz(g, nv(g)) == [1, 2, 3]

            g = SphereGraph()
            add_vertex!(g, [-1, -2, -3])
            @test xyz(g, nv(g)) == [-1, -2, -3]

            g = SphereGraph()
            add_vertex!(g, [0, 2, -3])
            @test xyz(g, nv(g)) == [0, 2, -3]

            g = SphereGraph()
            @test_throws Exception add_vertex!(g, [0, 2])

            g = SphereGraph()
            add_vertex!(g, [0, 2, -3, 5, 6])
            @test xyz(g, nv(g)) == [0, 2, -3]
        end

        @testset "Value" begin
            g = SphereGraph()
            add_vertex!(g, [1, 2, 3])
            @test get_value(g, nv(g)) == 0

            g = SphereGraph()
            add_vertex!(g, [1, 2, 3]; value=20)
            @test get_value(g, nv(g)) == 20

            g = SphereGraph()
            add_vertex!(g, [1, 2, 3]; value=-20)
            @test get_value(g, nv(g)) == -20

            g = SphereGraph()
            add_vertex!(g, [1, 2, 3]; value=0)
            @test get_value(g, nv(g)) == 0
        end

        @testset "Elevation" begin
            g = SphereGraph(3)
            add_vertex!(g, [1, 2, 2])   # r = 3
            @test get_elevation(g, nv(g)) == 0

            g = SphereGraph(4)
            add_vertex!(g, [1, 2, 2])   # r = 3
            @test get_elevation(g, nv(g)) == -1

            g = SphereGraph(2)
            add_vertex!(g, [1, 2, 2])   # r = 3
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(7)
            add_vertex!(g, [2, 3, 6])   # r = 7
            @test get_elevation(g, nv(g)) == 0

            g = SphereGraph(4)
            add_vertex!(g, [2, 3, 6])   # r = 7
            @test get_elevation(g, nv(g)) == 3

            g = SphereGraph(10)
            add_vertex!(g, [2, 3, 6])   # r = 7
            @test get_elevation(g, nv(g)) == -3

            g = SphereGraph(4)
            add_vertex!(g, [0, 3, 4])   # r = 5
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(4)
            add_vertex!(g, [3, 0, 4])   # r = 5
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(4)
            add_vertex!(g, [3, 4, 0])   # r = 5
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(4)
            add_vertex!(g, [5, 0, 0])   # r = 5
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(4)
            add_vertex!(g, [0, 5, 0])   # r = 5
            @test get_elevation(g, nv(g)) == 1

            g = SphereGraph(4)
            add_vertex!(g, [0, 0, 5])   # r = 5
            @test get_elevation(g, nv(g)) == 1
        end

        @testset "Longitude" begin
            longtitudes = [
                -135, -90, -45, 0, 45, 90, 135, 180
            ]
            coords = [
                -5  0  5  5  5  0 -5 -5   ;
                -5 -5 -5  0  5  5  5  0   ;
                -9 -5 -2  0  2  5  9  100 ;
            ]
            for (l, c) in zip(longtitudes, eachcol(coords))
                g = SphereGraph(5)
                add_vertex!(g, c)
                @test lon(g, nv(g)) ≈ l
            end
        end

        @testset "Latitude" begin
            latitudes = [
                -90, -45, -45, 0, 0, 0, 0, 45, 45, 90
            ]
            coords = [
                 0  0 -5  0 -5  5  10000  5  0  0 ;
                 0  5  0  5  0  5 -6      0 -5  0 ;
                -5 -5 -5  0  0  0  0      5  5  5 ;
            ]
            for (l, c) in zip(latitudes, eachcol(coords))
                g = SphereGraph(5)
                add_vertex!(g, c)
                @test lat(g, nv(g)) ≈ l
            end
        end
    end

    @testset "Spherical to Cartesian" begin
        @testset "Spherical" begin
            # Proper arguments
            proper_args = Dict(
                [0, 0] => [0, 0],
                [45, 0] => [45, 0],
                [-45, 0] => [-45, 0],
                [0, 90] => [0, 90],
                [0, -90] => [0, -90],
                [45, 90] => [45, 90],
                [-45, -90] => [-45, -90],
                [45, -90] => [45, -90],
                [45, -90] => [45, -90],
                [0, 180] => [0, 180],
                [0, -180] => [0, 180],
                [0,  181] => [0, -179],
                [0,  -181] => [0, 179],
                [0,  360] => [0, 0],
                [0,  -360] => [0, 0],
                [0,  361] => [0, 1],
                [0,  -361] => [0, -1],
                [0,  720] => [0, 0],
                [0,  -720] => [0, 0],
                [0,  721] => [0, 1],
                [0,  -721] => [0, -1]
            )
            for (arg, result) in proper_args
                g = SphereGraph()
                add_vertex!(g, arg, 0)
                @test gcs(g, nv(g)) == result
            end

            # Longitude is not important
            for latitude in [-90, 90], longitude in -180:45:180
                g = SphereGraph()
                add_vertex!(g, [latitude, longitude], 0)
                @test lat(g, nv(g)) == latitude
            end

            # Wrong arguments
            lats = [-361, -360, -181, -180, -179, -91, 91, 179, 180, 181, 360, 361]
            for latitude in lats, longitude in -360:45:360
                g = SphereGraph()
                @test_throws DomainError add_vertex!(g, [latitude, longitude], 0)
            end
        end

        @testset "Elevation" begin
            g = SphereGraph()
            add_vertex!(g, [20, 30], 10)
            @test get_elevation(g, nv(g)) == 10

            g = SphereGraph()
            add_vertex!(g,  [0, 30], 0)
            @test get_elevation(g, nv(g)) == 0

            g = SphereGraph()
            add_vertex!(g,  [30, 0], -10)
            @test get_elevation(g, nv(g)) == -10
        end

        @testset "Value" begin
            g = SphereGraph()
            add_vertex!(g, [20, 30], 10)
            @test get_value(g, nv(g)) == 0

            g = SphereGraph()
            add_vertex!(g,  [20, 30], 10; value=20)
            @test get_value(g, nv(g)) == 20

            g = SphereGraph()
            add_vertex!(g,  [20, 30], 10; value=-20)
            @test get_value(g, nv(g)) == -20

            g = SphereGraph()
            add_vertex!(g,  [20, 30], 10; value=0)
            @test get_value(g, nv(g)) == 0
        end

        @testset "Cartesian" begin
            @testset "Only Lat Lon" begin
                radius = 5
                mapping = Dict(
                    [[90, 45],      0]  =>  [0, 0, 5],
                    [[-90, -135],   0]  =>  [0, 0, -5],
                    [[0, 0],        0]  =>  [5*cosd(0), 5 * sind(0), 0],
                    [[0, 45],       0]  =>  [5*cosd(45), 5 * sind(45), 0],
                    [[0, 90],       0]  =>  [5*cosd(90), 5 * sind(90), 0],
                    [[0, 135],      0]  =>  [5*cosd(135), 5 * sind(135), 0],
                    [[0, 180],      0]  =>  [5*cosd(180), 5 * sind(180), 0],
                    [[0, -45],      0]  =>  [5*cosd(-45), 5 * sind(-45), 0],
                    [[0, -90],      0]  =>  [5*cosd(-90), 5 * sind(-90), 0],
                    [[0, -135],     0]  =>  [5*cosd(-135), 5 * sind(-135), 0],
                    [[45, 0],       0]  =>  [5*cosd(45), 0, 5 * sind(45)],
                    [[-45, 0],      0]  =>  [5*cosd(-45), 0, 5 * sind(-45)],
                    [[30, 0],       0]  =>  [5*cosd(30), 0, 5 * sind(30)],
                    [[60, 90],      0]  =>  [0, 2.5, 5 * sind(60)],
                    [[60, -90],     0]  =>  [0, -2.5, 5 * sind(60)],
                    [[60, 180],     0]  =>  [-2.5, 0, 5 * sind(60)],
                    [[60, 0],       0]  =>  [2.5, 0, 5 * sind(60)],
                    [[-60, 90],     0]  =>  [0, 2.5, -5 * sind(60)],
                    [[-60, -90],    0]  =>  [0, -2.5, -5 * sind(60)],
                    [[-60, 180],    0]  =>  [-2.5, 0, -5 * sind(60)],
                    [[-60, 0],      0]  =>  [2.5, 0, -5 * sind(60)],
                )
                for (arg, result) in mapping
                    g = SphereGraph(radius)
                    add_vertex!(g, arg[1], arg[2])
                    @test xyz(g, nv(g)) ≈ result
                end
            end

            @testset "Elevation" begin
                radius = 5
                mapping = Dict(
                    [[90, 45],      1]  =>  [0, 0, 6],
                    [[90, 45],     -1]  =>  [0, 0, 4],
                    [[-90, 45],      1]  =>  [0, 0, -6],
                    [[-90, 45],     -1]  =>  [0, 0, -4],
                    [[0, 0],        1]  =>  [6, 0, 0],
                    [[0, 0],       -1]  =>  [4, 0, 0],
                    [[0, 45],       5]  =>  [10*cosd(45), 10 * sind(45), 0],
                    [[0, -45],      5]  =>  [10*cosd(-45), 10 * sind(-45), 0],
                )
                for (arg, result) in mapping
                    g = SphereGraph(radius)
                    add_vertex!(g, arg[1], arg[2])
                    @test xyz(g, nv(g)) ≈ result
                end
            end
        end
    end
end
