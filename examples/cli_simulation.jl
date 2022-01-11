using MeshRefiner
using Dates

refinements = parse(Int64, ARGS[1])
steps = parse(Int64, ARGS[2])
dt = parse(Float64, ARGS[3])
waves = parse(Int64, ARGS[4])
N = parse(Float64, ARGS[5])
C = parse(Float64, ARGS[6])
save_next_row = parse(Int64, ARGS[7])
filename = string("output/simulation/", now())

"Set all values, so that water level is on the z=0 plane"
function set_values_to_0(g)
    for v in MeshRefiner.HyperGraphs.normal_vertices(g)
        MeshRefiner.HyperGraphs.set_value!(g, v, MeshRefiner.HyperGraphs.get_elevation(g, v) < 0 ? -MeshRefiner.HyperGraphs.get_elevation(g, v) : 0.0)
    end
end


"Create function that forms cosine \"donut\" with center in `center`, height
of `2c` and radius `2/N`"
function cos_wave(center, N, C)
    x0, y0 = center
    r(x, y) = sqrt((x - x0)^2 + (y - y0)^2)
    f(x, y) = r(x, y) > -2/N && r(x, y) < 2/N ? -C*cos(N * pi * r(x, y)) + C : 0.0
end

function cos_wave_2(center, N, C, waves=1)
    x0, y0 = center
    r(x, y) = sqrt((x - x0)^2 + (y - y0)^2)
    f(x, y) = r(x, y) > waves * (-2/N) && r(x, y) < waves * 2/N ? -C*cos(N*pi*r(x,y))*(abs(r(x,y))+1)+C*(abs(r(x,y))+1) : 0.0
end

function add_f_to_values(g, f)
    for v in MeshRefiner.HyperGraphs.normal_vertices(g)
        value = MeshRefiner.HyperGraphs.get_value(g, v)
        x, y = MeshRefiner.HyperGraphs.xyz(g, v)[1:2]
        new_value = f(x, y) + value
        MeshRefiner.HyperGraphs.set_value!(g, v, new_value)
    end
end

function set_f_to_values(g, f)
    for v in MeshRefiner.HyperGraphs.normal_vertices(g)
        x, y = MeshRefiner.HyperGraphs.xyz(g, v)[1:2]
        elev = MeshRefiner.HyperGraphs.get_elevation(g, v)
        value = f(x, y)  - elev
        value = value >= 0 ? value : 0.0
        MeshRefiner.HyperGraphs.set_value!(g, v, value)
    end
end

g = MeshRefiner.ProjectIO.load_GraphML("output/baltyk_iter15.xml")
g = MeshRefiner.GraphCreator.regular_pool_mesh(subdivisions=13, dims=(0, 800, 900, 1700), depth=0.1)
# f(x, y) = cos_wave([467589, 1274456], N, C)(x, y)
f(x, y) = cos_wave([467, 1274], 0.021, 0.6)(x, y)
f(p) = f(p[1], p[2])

# MeshRefiner.Adaptation.adapt_fun!(g, f, refinements)
set_f_to_values(g, f)
initial_values = MeshRefiner.HyperGraphs.get_all_values(g)

vs = collect(MeshRefiner.HyperGraphs.normal_vertices(g))
vs = filter(x -> MeshRefiner.HyperGraphs.coords2D(g,x)[2] > 1691694, vs)
vs = filter(x -> MeshRefiner.HyperGraphs.coords2D(g,x)[1] < 135304, vs)
condition(v) = v in vs

s = MeshRefiner.Simulation.simulate!(
    g,
    steps,
    dt,
    (x, y) -> 0;
    initial_values=initial_values)

MeshRefiner.ProjectIO.save_matrix(s, string(filename, ".txt"), next_row=save_next_row)
MeshRefiner.ProjectIO.save_GraphML(g, string(filename, ".xml"))
