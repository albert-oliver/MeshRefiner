module Derivations

include("../utils.jl")
include("../transformations/transformations.jl")
include("../adaptation/adaptation.jl")
include("../graph_creator/graph_creator.jl")
include("../visualization/visualization.jl")
include("../io.jl")
include("../simulation/sim.jl")

# using .ProjectIO
using .Utils
using .Adaptation
using .GraphCreator
using .Transformations
using .Visualization
using .Simulation

using LightGraphs
using MetaGraphs
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
            set_prop!(g, i, :refine, true)
        end
        run_transformations!(g)
    end
    best_v = 0
    best_x = 1
    best_y = 1
    for v in normal_vertices(g)
        if abs(x(g, v) - half) < best_x && abs(y(g, v) - half) < best_y
            best_x = abs(x(g, v) - half)
            best_y = abs(y(g, v) - half)
            best_v = v
        end
        set_prop!(g, v, :value, 1)
    end
    set_prop!(g, best_v, :value, 100)
    # draw_graphplot(g)
    simulate(g, steps, dt)
end

function test_save()
    g = simple_graph()
    saveGML(g, "a.gml")
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

end
