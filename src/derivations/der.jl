module Derivations

include("../hypergraphs/hypergraphs.jl")
include("../utils.jl")
include("../transformations/transformations.jl")
include("../adaptation/adaptation.jl")
include("../graph_creator/graph_creator.jl")
include("../visualization/visualization.jl")
include("../io.jl")
include("../simulation/sim.jl")

using .HyperGraphs
using .Utils
using .Transformations
using .Adaptation
using .GraphCreator
using .Visualization
using .ProjectIO
using .Simulation

using LinearAlgebra
using Statistics
using Compose
import Cairo, Fontconfig

function test_sim(steps=4, adapt_steps=10, dt=0.1)
    size = 100
    half = size/2
    g = simple_graph(size)
    for step in 1:adapt_steps
        for i in interiors(g)
            set_refine!(g, i)
        end
        run_transformations!(g)
    end
    best_v = 0
    best_x = 1
    best_y = 1
    for v in normal_vertices(g)
        x, y, z = xyz(g, v)
        if abs(x - half) < best_x && abs(y - half) < best_y
            best_x = abs(x - half)
            best_y = abs(y - half)
            best_v = v
        end
        set_value!(g, v, 1)
    end
    set_value!(g, best_v, 100)
    # draw_graphplot(g)
    simulate!(g, steps, dt, (x, y) -> 0)
end

function test_adapt_fun()
    g = simple_graph()
    ρ = 100
    u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
    u(vec) = u(vec[1], vec[2])

    adapt_fun!(g, u, 10)
    export_obj(g, "a.obj")
    draw_makie(g)
end

function test_adapt_both()
    terrain = load_heightmap("resources/poland.png", (100,100), 10.0)
    g = generate_terrain_mesh(terrain, 0.005, 15)
    export_obj(g, "terrain1.obj")
    println("Terrain done!")

    ρ = 30
    u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
    fun(x, y) = u(x/100, y/100) * 30
    fun(vec) = fun(vec[1], vec[2])
    adapt_fun!(g, fun, 15)
    export_obj(g, "fun1.obj")
    export_obj(g, "both1.obj", true)
    draw_makie(g, include_fun=true)
end

function start(ϵ, iters=15)
    # t_map = load_data("resources/poland500_fixed.data")
    terrain = load_heightmap("resources/poland.png", (100,100), 10.0)

    g = generate_terrain_mesh(terrain, ϵ, iters)

    println("Visualizing...")
    draw_makie(g)
end

function interactive_test()
    g = simple_graph()
    i = 1
    while true
        draw(PNG(string("resources/testgraph", i, ".png"), 16cm, 16cm), draw_graphplot(g; vid=true))
        print("To refine (q to quit): ")
        s = readline()
        if (s == "q")
            break
        end
        splitted = split(s)
        for svertex in splitted
            v = parse(Int64, svertex)
            set_refine!(g, v)
        end
        run_transformations!(g; log=true)
        i += 1
    end
end

end
