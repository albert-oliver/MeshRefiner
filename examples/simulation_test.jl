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
# f1(x, y) = cos_wave([467589, 1274456], 0.000031, 600)(x, y)
# f1(p) = f1(p[1], p[2])
# f2(x,y) = cos_wave([467589, 1274456], 0.000020, 590)(x, y)
# f2(p) = f2(p[1], p[2])
waves = 1
f1(x, y) = cos_wave_2([467589, 1274456], 0.00007, 0.018 / waves, waves)(x, y)
f1(p) = f1(p[1], p[2])

MeshRefiner.Adaptation.adapt_fun!(g, f1, 7)
# MeshRefiner.Adaptation.adapt_fun!(g, f2, 4)

set_values_to_0(g)
set_f_to_values(g, f1)
v1 = MeshRefiner.HyperGraphs.get_all_values(g)
# set_values_to_0(g)
# add_f_to_values(g, f2)
# v2 = MeshRefiner.HyperGraphs.get_all_values(g)
# initital_values = transpose(hcat(v1, v2))
initital_values = v1

vs = collect(MeshRefiner.HyperGraphs.normal_vertices(g))
vs = filter(x -> MeshRefiner.HyperGraphs.coords2D(g,x)[2] > 1691694, vs)
vs = filter(x -> MeshRefiner.HyperGraphs.coords2D(g,x)[1] < 135304, vs)
condition(v) = v in vs
