using MeshRefiner

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
function cos_wave(center, N, c)
    x0, y0 = center
    r(x, y) = sqrt((x - x0)^2 + (y - y0)^2)
    f(x, y) = r(x, y) > -2/N && r(x, y) < 2/N ? -c*cos(N * pi * r(x, y)) + c : 0.0
end

function add_f_to_values(g, f)
    for v in MeshRefiner.HyperGraphs.normal_vertices(g)
        value = MeshRefiner.HyperGraphs.get_value(g, v)
        x, y = MeshRefiner.HyperGraphs.xyz(g, v)[1:2]
        new_value = f(x, y) + value
        MeshRefiner.HyperGraphs.set_value!(g, v, new_value)
    end
end

f1 = cos_wave([467589, 1274456], 0.000031, 2000)
f2 = cos_wave([467589, 1274456], 0.00002, 1960)
set_values_to_0(g)
add_f_to_values(g, f1)
v1 = MeshRefiner.HyperGraphs.get_all_values(g)
set_values_to_0(g)
add_f_to_values(g, f2)
v2 = MeshRefiner.HyperGraphs.get_all_values(g)
initital_values = transpose(hcat(v1, v2))
