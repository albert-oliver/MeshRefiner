include("../src/MeshRefiner.jl")

function test_sim(steps=4, adapt_steps=10, dt=0.1)
    size = 100
    half = size/2
    g = MeshRefiner.simple_graph(size)
    for step in 1:adapt_steps
        for i in MeshRefiner.HyperGraphs.interiors(g)
            MeshRefiner.HyperGraphs.set_refine!(g, i)
        end
        MeshRefiner.Transformations.refine!(g)
    end
    best_v = 0
    best_x = 1
    best_y = 1
    for v in MeshRefiner.HyperGraphs.normal_vertices(g)
        x, y, z = MeshRefiner.HyperGraphs.xyz(g, v)
        if abs(x - half) < best_x && abs(y - half) < best_y
            best_x = abs(x - half)
            best_y = abs(y - half)
            best_v = v
        end
        MeshRefiner.HyperGraphs.set_value!(g, v, 1)
    end
    MeshRefiner.HyperGraphs.set_value!(g, best_v, 100)
    # draw_graphplot(g)
    MeshRefiner.simulate!(g, steps, dt, (x, y) -> 0)
end
