include("../derivations/der.jl")



g = Derivations.GraphCreator.regular_flat_mesh(; subdivisions=8, dims=(10.0, 10.0))
r = Derivations.Simulation.simulate!(g, 2, 0.002, (x, y) -> 1.0)
Derivations.Visualization.draw_makie(g, include_fun=true)

Derivations.ProjectIO.export_simulation(g, r; fps=30)


g = Derivations.GraphCreator.mesh_hat_fun((10.0, 10.0), 6.0)
s = Derivations.Simulation.simulate!(g, 1000, 0.002, (x, y) -> 0.0)
s
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)

Derivations.ProjectIO.export_simulation(g, s2; fps=24)

g = Derivations.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = Derivations.GraphCreator.hat_fun([2.5, 5], [5, 5], 2.0)
Derivations.Adaptation.match_to_fun!(g, f)
s = Derivations.Simulation.simulate!(g, 100, 0.002, (x, y) -> 0.0; α=5/3)
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
Derivations.ProjectIO.export_simulation(g, s; fps=30)



g = Derivations.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = Derivations.GraphCreator.block_fun([0.5, 0.5], [2, 9], 6.0)
Derivations.Adaptation.match_to_fun!(g, f)
s = Derivations.Simulation.simulate!(g, 10000, 0.002, (x, y) -> 0.0; α=5/3)
s
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
Derivations.ProjectIO.export_simulation(g, s; fps=120)


t = Derivations.ProjectIO.load_heightmap("resources/water_way_small.png", (10.0, 10.0), 10.0)
g = Derivations.Adaptation.generate_terrain_mesh(t, 0.001)
Derivations.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

t = Derivations.ProjectIO.load_heightmap("resources/hill.png", (10.0, 10.0), 9.0)
g = Derivations.Adaptation.generate_terrain_mesh(t, 0.0001)
Derivations.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

t = MeshRefiner.ProjectIO.load_heightmap("resources/valley.png", (10.0, 10.0), 9.0)
g = MeshRefiner.Adaptation.generate_terrain_mesh(t, 0.0001)
MeshRefiner.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

Derivations.Adaptation.match_to_fun!(g, (x, y) -> 0.0)
f = Derivations.GraphCreator.hat_fun([2.5, 5], [5, 5], 4.0)
Derivations.Adaptation.match_to_fun!(g, f)
s3 = Derivations.Simulation.simulate!(g, 10000, 0.002, (x, y) -> 0.0; α=5/3)

Derivations.Utils.set_values!(g, s[800, :])
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false, shading_fun=true)
Derivations.ProjectIO.export_simulation(g, s3; fps=120)

function ex(; kwargs...)
    println(kwargs[:a])
end
