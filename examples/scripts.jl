import MeshGraphs

g = MeshRefiner.GraphCreator.regular_flat_mesh(; subdivisions=8, dims=(10.0, 10.0))
r = MeshRefiner.Simulation.simulate!(g, 2, 0.002, (x, y) -> 1.0)
MeshRefiner.Visualization.draw_makie(g, include_fun=true)

MeshRefiner.ProjectIO.export_simulation(g, r; fps=30)


g = MeshRefiner.GraphCreator.mesh_hat_fun((10.0, 10.0), 6.0)
s = MeshRefiner.Simulation.simulate!(g, 1000, 0.002, (x, y) -> 0.0)
s
MeshRefiner.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)

MeshRefiner.ProjectIO.export_simulation(g, s2; fps=24)

g = MeshRefiner.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = MeshRefiner.GraphCreator.hat_fun([2.5, 5], [5, 5], 2.0)
MeshRefiner.Adaptation.match_to_fun!(g, f)
s = MeshRefiner.Simulation.simulate!(g, 100, 0.002, (x, y) -> 0.0; α=5/3)
MeshRefiner.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
MeshRefiner.ProjectIO.export_simulation(g, s; fps=30)



g = MeshRefiner.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = MeshRefiner.GraphCreator.block_fun([0.5, 0.5], [2, 9], 6.0)
MeshRefiner.Adaptation.match_to_fun!(g, f)
s = MeshRefiner.Simulation.simulate!(g, 10000, 0.002, (x, y) -> 0.0; α=5/3)
s
MeshRefiner.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
MeshRefiner.ProjectIO.export_simulation(g, s; fps=120)


t = MeshRefiner.ProjectIO.load_heightmap("resources/water_way_small.png", (10.0, 10.0), 10.0)
g = MeshRefiner.Adaptation.generate_terrain_mesh(t, 0.001)
MeshRefiner.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

t = MeshRefiner.ProjectIO.load_heightmap("resources/hill.png", (10.0, 10.0), 9.0)
g = MeshRefiner.Adaptation.generate_terrain_mesh(t, 0.0001)
MeshRefiner.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

t = MeshRefiner.ProjectIO.load_heightmap("resources/valley.png", (10.0, 10.0), 9.0)
g = MeshRefiner.Adaptation.generate_terrain_mesh(t, 0.0001)
MeshRefiner.Adaptation.match_to_fun!(g, (x, y) -> 0.0)

MeshRefiner.Adaptation.match_to_fun!(g, (x, y) -> 0.0)
f = MeshRefiner.GraphCreator.hat_fun([2.5, 5], [5, 5], 4.0)
MeshRefiner.Adaptation.match_to_fun!(g, f)
s3 = MeshRefiner.Simulation.simulate!(g, 10000, 0.002, (x, y) -> 0.0; α=5/3)

MeshRefiner.Utils.set_values!(g, s[800, :])
MeshRefiner.Visualization.draw_makie(g, include_fun=true, transparent_fun=false, shading_fun=true)
MeshRefiner.ProjectIO.export_simulation(g, s3; fps=120)
