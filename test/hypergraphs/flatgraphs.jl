using MeshRefiner.HyperGraphs

import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs

@testset "SphereGraph" begin
    g = FlatGraph()
    @test g.vertex_count == 0
    @test g.interior_count == 0
    @test g.hanging_count == 0
    @test Gr.nv(g.graph) == 0
    @test Gr.ne(g.graph) == 0

    @testset "add_vertex!" begin
        @testset "Coordinates" begin
            g = FlatGraph()
            add_vertex!(g, [1, 2, 3])
            @test xyz(g, nv(g)) == [1, 2, 3]

            g = FlatGraph()
            add_vertex!(g, [-1, -2, -3])
            @test xyz(g, nv(g)) == [-1, -2, -3]

            g = FlatGraph()
            add_vertex!(g, [0, 2, -3])
            @test xyz(g, nv(g)) == [0, 2, -3]

            g = FlatGraph()
            @test_throws Exception add_vertex!(g, [0, 2])

            g = FlatGraph()
            add_vertex!(g, [0, 2, -3, 5, 6])
            @test xyz(g, nv(g)) == [0, 2, -3]
        end

        @testset "Elevation" begin
            g = FlatGraph()
            add_vertex!(g, [1, 2], 3)
            @test get_elevation(g, 1) == 3

            g = FlatGraph()
            add_vertex!(g, [1, 2, 3])
            @test get_elevation(g, 1) == 3
        end
    end
end
