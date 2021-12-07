include("../src/MeshRefiner.jl")

function test_adapt_fun()
    g = MeshRefiner.simple_graph()
    ρ = 100
    u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
    u(vec) = u(vec[1], vec[2])

    MeshRefiner.adapt_fun!(g, u, 10)
    MeshRefiner.draw_makie(g)
end
