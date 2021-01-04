module Derivations

include("../io.jl")
include("../utils.jl")
include("../transformations/transformations.jl")
include("../adaptation/adaptation.jl")
include("../graph_creator/graph_creator.jl")
include("../visualization/visualization.jl")

using .ProjectIO
using .Utils
using .Adaptation
using .GraphCreator
using .Transformations
using .Visualization

using LightGraphs
using MetaGraphs
using LinearAlgebra
using Statistics
using Compose
import Cairo, Fontconfig

function test_adapt_fun()
    g = simple_graph()
    ρ = 100
    u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
    u(vec) = u(vec[1], vec[2])

    adapt_fun(g, u, 10)
    draw_makie(g)
end

function start()
    # t_map = load_data("resources/poland500_fixed.data")
    t_map = load_heightmap("resources/heightmap.png")
    g = initial_graph(t_map)

    accuracy = 1000

    for i in 1:18
        print(i, ": ")
    # while true
        to_refine = mark_for_refinement(g, t_map, accuracy)
        if isempty(to_refine)
            break
        end
        run_transformations!(g)
        adjust_heights(g, t_map)
    end

    println("Visualizing...")
    draw_makie(g)
end

function interactive_test()
    g = simple_graph()
    i = 1
    while true
        draw(PNG(string("resources/testgraph", i, ".png"), 16cm, 16cm), draw_graphplot(g, true))
        print("To refine (q to quit): ")
        s = readline()
        if (s == "q")
            break
        end
        splitted = split(s)
        for svertex in splitted
            v = parse(Int64, svertex)
            set_prop!(g, v, :refine, true)
        end
        run_transformations!(g, true)
        i += 1
    end
end

start()
end
