include("../derivations/der.jl")



g = Derivations.GraphCreator.regular_flat_mesh(10; dims=(10.0, 10.0))
s2 = Derivations.Simulation.simulate!(g, 1000, 0.002, (x, y) -> 1.0)
Derivations.Visualization.draw_makie(g, include_fun=true)

Derivations.ProjectIO.export_simulation(g, s; fps=24)


g = Derivations.GraphCreator.mesh_hat_fun((10.0, 10.0), 6.0)
s = Derivations.Simulation.simulate!(g, 1000, 0.002, (x, y) -> 0.0)
s
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)

Derivations.ProjectIO.export_simulation(g, s2; fps=24)

g = Derivations.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = Derivations.GraphCreator.hat_fun([2.5, 5], [5, 5], 6.0)
Derivations.Adaptation.match_to_fun!(g, f)
s = Derivations.Simulation.simulate!(g, 1000, 0.002, (x, y) -> 0.0)
s
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
Derivations.ProjectIO.export_simulation(g, s; fps=30)


g = Derivations.GraphCreator.regular_channel_mesh(dims=(10.0,10.0), height=6.0)
f = Derivations.GraphCreator.block_fun([0.5, 0.5], [2, 9], 6.0)
Derivations.Adaptation.match_to_fun!(g, f)
s = Derivations.Simulation.simulate!(g, 5000, 0.002, (x, y) -> 0.0)
s
Derivations.Visualization.draw_makie(g, include_fun=true, transparent_fun=false)
Derivations.ProjectIO.export_simulation(g, s; fps=60)
