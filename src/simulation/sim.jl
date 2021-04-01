"Modul that is responsible for all simulations on mesh,"
module Simulation

export simulate

using LightGraphs
using MetaGraphs

using ..Utils
using ..ProjectIO

"""
    common_triangles(h, i, j)

Return common triangles of vertices `i` and `j`. Common traingles are all
triangles with both `i` and `j` as its vertices.
"""
function common_triangles(g, i, j)
    interiors1 = filter(v -> get_prop(g, v, :type) == "interior", neighbors(g, i))
    interiors2 = filter(v -> get_prop(g, v, :type) == "interior", neighbors(g, j))
    intersect(interiors1, interiors2)
end

function triangles_with_vertex(g, i)
    filter(v -> get_prop(g, v, :type) == "interior", neighbors(g, i))
end

function set_values!(g, a)
    for (i, v) in enumerate(normal_vertices(g))
        set_prop!(g, v, :value, a[i])
    end
end

"""
    simulate(g, steps, dt)

Perform flood simulation on previously generated mesh `g`. Length of each time
step is `dt`.

Note that graph `g` should have been adapted to function representing starting
water level using `adapt_fun!`.
"""
function simulate(g, steps, dt)
    v_map::Dict{Integer, Integer} = Dict()
    for (index, v) in enumerate(normal_vertices(g))
        v_map[v] = index
    end

    vertices_count = length(v_map)
    M = zeros((vertices_count, vertices_count))

    for step in 1:steps
        export_obj(g, string("sim", step, ".obj"), true)

        for vᵢ in normal_vertices(g)
            for vⱼ in filter(v -> get_prop(g, v, :type) == "vertex", neighbors(g, vᵢ))
                i = v_map[vᵢ]
                j = v_map[vⱼ]
                M[i, j] = sum(interior -> (1/12) * projection_area(g, interior), common_triangles(g, vᵢ, vⱼ))
            end
        end

        # RHS
        # (1)
        aᵗ = map(v -> get_prop(g, v, :value), normal_vertices(g))
        # first = M*aᵗ

        first = zeros(vertices_count)
        for vᵢ in normal_vertices(g)
            i = v_map[vᵢ]
            for interior in triangles_with_vertex(g, vᵢ)
                a, b, c = map(v -> coords(g, v), interior_vertices(g, interior))
                xs, ys = center_point([a,b,c])[1:2]
                e = pyramid_function(g, interior, vᵢ)
                first[i] += e([xs, ys]) * (1/2) * projection_area(g, interior)
            end
            first[i] = dt * first[i]
        end

        # (2)
        second = zeros(vertices_count)
        for vᵢ in normal_vertices(g)
            i = v_map[vᵢ]
            for interior in triangles_with_vertex(g, vᵢ)
                a, b, c = map(v -> coords(g, v), interior_vertices(g, interior))
                hx = (max(x(a), x(b), x(c)) - min(x(a), x(b), x(c))) / 4
                hy = (max(y(a), y(b), y(c)) - min(y(a), y(b), y(c))) / 4
                xs, ys = center_point([a,b,c])[1:2]
                u = approx_function(g, interior)
                ∂u∂x = (u([xs + hx, ys]) - u([xs - hx, ys])) / (2 * hx)
                ∂u∂y = (u([xs, ys + hy]) - u([xs, ys - hy])) / (2 * hy)
                e = pyramid_function(g, interior, vᵢ)
                ∂e∂x = (e([xs + hx, ys]) - e([xs - hx, ys])) / (2 * hx)
                ∂e∂y = (e([xs, ys + hy]) - e([xs, ys - hy])) / (2 * hy)

                second[i] += (∂u∂x * ∂e∂x + ∂u∂y * ∂e∂y) * projection_area(g, interior)
            end
            second[i] = -dt * second[i]
        end

        RHS = first + second
        aᵗ⁺¹ = M \ RHS
        set_values!(g, aᵗ⁺¹)
    end
end

end
