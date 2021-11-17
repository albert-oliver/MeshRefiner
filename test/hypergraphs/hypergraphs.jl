using MeshRefiner.HyperGraphs

import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs

@testset verbose = true "HyperGraph" begin
    include("spheregraphs.jl")
    include("flatgraphs.jl")

    @testset "Unit tests" begin
        @testset "add_vertex!" begin
            @testset "Single vertex" begin
                for g in [SphereGraph(), FlatGraph()]
                    g = SphereGraph(100)
                    add_vertex!(g, [1, 2, 2])
                    @test g.vertex_count == 1
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 1
                    @test Gr.ne(g.graph) == 0

                    g = SphereGraph(100)
                    add_vertex!(g, [3, 5], 10)
                    @test g.vertex_count == 1
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 1
                    @test Gr.ne(g.graph) == 0

                    g = SphereGraph(100)
                    add_vertex!(g, [1, 2, 3]; value = 10)
                    @test g.vertex_count == 1
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 1
                    @test Gr.ne(g.graph) == 0

                    g = SphereGraph(100)
                    add_vertex!(g, [1, 2], 10; value = 10)
                    @test g.vertex_count == 1
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 1
                    @test Gr.ne(g.graph) == 0
                end
            end

            @testset "Multiple vertices" begin
                for g in [SphereGraph(), FlatGraph()]
                    g = SphereGraph(100)
                    add_vertex!(g, [1, 2, 2])
                    @test g.vertex_count == 1
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 1
                    @test Gr.ne(g.graph) == 0

                    add_vertex!(g, [1, 3, 5])
                    @test g.vertex_count == 2
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 2
                    @test Gr.ne(g.graph) == 0

                    add_vertex!(g, [0, 1, 0])
                    @test g.vertex_count == 3
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 3
                    @test Gr.ne(g.graph) == 0

                    add_vertex!(g, [4, 6, 1])
                    @test g.vertex_count == 4
                    @test g.interior_count == 0
                    @test g.hanging_count == 0
                    @test g.radius == 100
                    @test Gr.nv(g.graph) == 4
                    @test Gr.ne(g.graph) == 0
                end
            end
        end

        @testset "add_edge!" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [3, 0, 0])
                add_vertex!(g, [0, 4, 0])
                add_vertex!(g, [0, 0, 4])

                add_edge!(g, 1, 2)
                add_edge!(g, 1, 3; boundary=true)

                @test has_edge(g, 1, 2)
                @test has_edge(g, 1, 3)
                @test !has_edge(g, 2, 3)

                @test !is_on_boundary(g, 1, 2)
                @test is_on_boundary(g, 1, 3)
            end
        end

        @testset "rem_edge!" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [3, 0, 0])
                add_vertex!(g, [0, 4, 0])
                add_vertex!(g, [0, 0, 4])

                add_edge!(g, 1, 2)
                add_edge!(g, 1, 3; boundary=true)

                rem_edge!(g, 1, 2)

                @test !has_edge(g, 1, 2)
                @test has_edge(g, 1, 3)
                @test !has_edge(g, 2, 3)
            end
        end

        @testset "add_hanging!" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [6, 0, 0])
                add_vertex!(g, [0, 4, 0])
                add_hanging!(g, 1, 2, [3, 2, 0])
                add_vertex!(g, [2, 4], 1)
                add_vertex!(g, [4, 6], 2)
                add_hanging!(g, 5, 6, [3, 5], 1)

                @test vertex_count(g) == 4
                @test hanging_count(g) == 2
                @test interior_count(g) == 0
                @test nv(g) == 6

                @test !is_hanging(g, 1)
                @test !is_hanging(g, 2)
                @test is_hanging(g, 3)
                @test !is_hanging(g, 4)
                @test !is_hanging(g, 5)
                @test is_hanging(g, 6)
            end
        end

        @testset "add_interior!" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                v1 = add_vertex!(g, [5, 0, 0])
                v2 = add_vertex!(g, [0, 5, 0])
                v3 = add_vertex!(g, [0, 0, 5])
                i1 = add_interior!(g, 1, 2, 3)
                v4 = add_vertex!(g, [0, -5, 0])
                i2 = add_interior!(g, 1, 3, 5; refine=true)

                @test vertex_count(g) == 4
                @test hanging_count(g) == 0
                @test interior_count(g) == 2
                @test nv(g) == 6

                @test is_interior(g, i1)
                @test is_interior(g, i2)
                @test !is_interior(g, v1)
                @test !is_interior(g, v2)
                @test !is_interior(g, v3)
                @test !is_interior(g, v4)

                @test Set(interiors_vertices(g, i1)) == Set([v1, v2, v3])
                @test Set(interiors_vertices(g, i2)) == Set([v1, v3, v4])

                @test !should_refine(g, i1)
                @test should_refine(g, i2)
            end
        end

        @testset "rem_vertex!" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [3, 0, 0])
                add_vertex!(g, [0, 4, 0])
                add_vertex!(g, [3, 4, 0])

                rem_vertex!(g, 2)

                @test vertex_count(g) == 2
                @test hanging_count(g) == 0
                @test interior_count(g) == 0
                @test nv(g) == 2

                for v in 1:nv(g)
                    xyz(g, v) in [[3, 0, 0], [3, 4, 0]]
                end
            end
        end

        @testset "edge_length" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [3, 0, 0])
                add_vertex!(g, [0, 4, 0])
                add_edge!(g, 1, 2)

                @test edge_length(g, 1, 2) ≈ 5.0
            end
        end

        @testset "get_hanging_node_between" begin
            gs = [SphereGraph(), FlatGraph()]
            for g in gs
                add_vertex!(g, [1, 3, 0])
                add_vertex!(g, [3, 3, 0])
                add_hanging!(g, 1, 2, [2, 3, 0])
                add_vertex!(g, [1, 2, 0])
                add_vertex!(g, [3, 2, 0])
                add_hanging!(g, 4, 5, [2, 2, 0])
                add_vertex!(g, [1, 1, 0])
                add_vertex!(g, [3, 1, 0])
                add_hanging!(g, 7, 8, [2, 1, 0])

                add_edge!(g, 1, 3)
                add_edge!(g, 3, 2)
                add_edge!(g, 4, 6)
                add_edge!(g, 6, 5)
                add_edge!(g, 7, 9)
                add_edge!(g, 8, 9)
                add_edge!(g, 1, 4)
                add_edge!(g, 4, 7)
                add_edge!(g, 2, 5)
                add_edge!(g, 5, 8)
                add_edge!(g, 3, 4)
                add_edge!(g, 3, 6)
                add_edge!(g, 3, 5)
                add_edge!(g, 4, 9)
                add_edge!(g, 9, 5)

                add_interior!(g, 1, 3, 4)
                add_interior!(g, 3, 4, 5)
                add_interior!(g, 2, 3, 5)
                add_interior!(g, 3, 5, 6)
                add_interior!(g, 4, 7, 9)
                add_interior!(g, 4, 5, 9)
                add_interior!(g, 5, 8, 9)

                @test get_hanging_node_between(g, 1, 2) == 3
                @test get_hanging_node_between(g, 4, 5) == 6
                @test get_hanging_node_between(g, 7, 8) == 9
            end
        end
    end

    @testset "Example Graph" begin
        function sample_graph(g_type)
            g = g_type()
            add_vertex!(g, [0, 6, 0])             # 1
            add_vertex!(g, [6, 6, 3])             # 2
            add_vertex!(g, [12, 6, 1])            # 3
            add_vertex!(g, [6, 12, 5])            # 4
            add_vertex!(g, [0, 0, 0])             # 5
            add_vertex!(g, [6, 0, 2])             # 6
            add_vertex!(g, [12, 0, 1])            # 7

            add_hanging!(g, 3, 4, [9, 4.5, 3])    # 8

            add_interior!(g, 1, 2, 4)             # 9
            add_interior!(g, 1, 4, 5)             # 10
            add_interior!(g, 2, 4, 8)             # 11
            add_interior!(g, 2, 3, 8)             # 12
            add_interior!(g, 3, 4, 7)             # 13
            add_interior!(g, 4, 5, 6)             # 14
            add_interior!(g, 4, 6, 7)             # 15

            add_edge!(g, 1, 2; boundary=true)
            add_edge!(g, 2, 3; boundary=true)
            add_edge!(g, 3, 7; boundary=true)
            add_edge!(g, 7, 6; boundary=true)
            add_edge!(g, 6, 5; boundary=true)
            add_edge!(g, 5, 1; boundary=true)
            add_edge!(g, 1, 4)
            add_edge!(g, 2, 4)
            add_edge!(g, 2, 8)
            add_edge!(g, 3, 8)
            add_edge!(g, 4, 8)
            add_edge!(g, 5, 4)
            add_edge!(g, 4, 6)
            add_edge!(g, 4, 7)
            g
        end

        edges = [
            1 2 3 7 6 5 1 2 2 3 4 5 4 4 ;
            2 3 7 6 5 1 4 4 8 8 8 4 6 7
        ]
        b_edges = [
            1 2 3 7 6 5 ;
            2 3 7 6 5 1
        ]
        vs = 1:7
        hs = [8]
        inters = 9:15

        sample_sphere_graph = () -> sample_graph(SphereGraph)
        sample_flat_graph = () -> sample_graph(FlatGraph)

        function test_edges(g, edges, b_edges)
            for v1 in vertices_except_type(g, INTERIOR), v2 in vertices_except_type(g, INTERIOR)
                if Set([v1, v2]) in map(e -> Set(e), eachcol(edges))
                    @test has_edge(g, v1, v2)
                    if Set([v1, v2]) in map(e -> Set(e), eachcol(b_edges))
                        @test is_on_boundary(g, v1, v2)
                    else
                        @test !is_on_boundary(g, v1, v2)
                    end
                else
                    @test !has_edge(g, v1, v2)
                end
            end
        end

        function test_types_and_count(g, vs, hs, inters)
            @test vertex_count(g) == length(vs)
            @test hanging_count(g) == length(hs)
            @test interior_count(g) == length(inters)
            @test nv(g) == length(vs) +  length(hs) +  length(inters)

            for v in vs
                @test is_vertex(g, v)
                @test !is_hanging(g, v)
                @test !is_interior(g, v)
            end

            for h in hs
                @test !is_vertex(g, h)
                @test is_hanging(g, h)
                @test !is_interior(g, h)
            end

            for i in inters
                @test !is_vertex(g, i)
                @test !is_hanging(g, i)
                @test is_interior(g, i)
            end
        end

        @testset "Basic" begin
            for g in [sample_sphere_graph(), sample_flat_graph()]
                test_edges(g, edges, b_edges)
                test_types_and_count(g, vs, hs, inters)
            end
        end
    end
end
