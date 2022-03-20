using MeshRefiner.Utils

using MeshRefiner.Adaptation

using MeshGraphs

@testset verbose = true "Utils" begin

    function triangle_graph()
        g = FlatGraph()
        add_vertex!(g, [4, 3, 0]; value=2)
        add_vertex!(g, [2, 3, 2]; value=1)
        add_vertex!(g, [6, 6, 1]; value=3)
        add_interior!(g, 1, 2, 3)
        add_edge!(g, 1, 2)
        add_edge!(g, 1, 3)
        add_edge!(g, 2, 3)
        g
    end

    @testset "Basic" begin

        @testset "center_point" begin
            @test center_point([[1.0], [2.0], [3.0]]) == [2.0]
            @test center_point([[1], [2], [3]]) == [2]
            @test center_point([[1,2], [2,3], [3,4]]) == [2, 3]
        end

        @testset "approx_function" begin
            g = triangle_graph()
            f = approx_function(g, nv(g))
            @test f([4, 4]) == 2    # center
            @test f([4, 3]) == 2    # vertex
            @test f([2, 3]) == 1    # vertex
            @test f([6, 6]) == 3    # vertex
            @test f([5.25, 5.25]) == 2.625
        end

        @testset "projection_area" begin
            @test projection_area([0,0], [0,6], [2, 0]) == 6
            @test projection_area([0,0, 1], [0,6, 2], [2, 0, 3]) == 6
            @test projection_area([2,3], [7,3], [4, 9]) == 15
            @test projection_area([2,3, 1], [7, 3, 2], [4, 9, 3]) == 15

            @test projection_area(Triangle(([0, 0], [0, 6], [2, 0]))) == 6
            @test projection_area(Triangle(([0, 0, 1], [0, 6, 2], [2, 0, 3]))) == 6
            @test projection_area(Triangle(([2, 3], [7, 3], [4, 9]))) == 15
            @test projection_area(Triangle(([2, 3, 1], [7, 3, 2], [4, 9, 3]))) == 15

            @test projection_area(triangle_graph(), 4) == 3
        end

        @testset "pyramid_function" begin
            g = triangle_graph()
            e = pyramid_function(g, nv(g), 1)
            @test isapprox(e([4, 4]), 1/3)    # center
            @test e([4, 3]) == 1    # vertex
            @test e([2, 3]) == 0    # vertex
            @test e([6, 6]) == 0    # vertex

            e = pyramid_function(g, nv(g), 2)
            @test isapprox(e([4, 4]), 1/3)    # center
            @test e([4, 3]) == 0    # vertex
            @test e([2, 3]) == 1    # vertex
            @test e([6, 6]) == 0    # vertex

            e = pyramid_function(g, nv(g), 3)
            @test isapprox(e([4, 4]), 1/3)    # center
            @test e([4, 3]) == 0    # vertex
            @test e([2, 3]) == 0    # vertex
            @test e([6, 6]) == 1    # vertex
        end

    end # @testset "Baisc"

    include("terrain_map.jl")


end # @testset "Utils"
