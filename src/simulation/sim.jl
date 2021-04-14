"Modul that is responsible for all simulations on mesh,"
module Simulation

export simulate!

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

"""
    simulate!(g, steps, dt, f)

Perform flood simulation on previously generated mesh `g`. Length of each time
step is `dt`.

Note that graph `g` should have been adapted to function representing starting
water level using `adapt_fun!`.
"""
function simulate!(g, steps, dt, f; γ=1.0, α=0.5, β=0.5)
    result = reshape(map(v -> get_prop(g, v, :value), normal_vertices(g)), 1, :)
    v_map = vertex_map(g)
    vertices_count = length(v_map)

    # This matrix doesn't change
    M = zeros((vertices_count, vertices_count))
    for interior in interiors(g)
        for vᵢ in interior_vertices(g, interior)
            for vⱼ in interior_vertices(g, interior)
                i = v_map[vᵢ]
                j = v_map[vⱼ]
                area = projection_area(g, interior)
                if i == j
                    M[i, j] += (1/6) * area
                else
                    M[i, j] += (1/12) * area
                end
            end
        end
    end
    inv_M = inv(M)

    for step in 1:steps
        # RHS
        # (1)
        aᵗ = map(v -> get_prop(g, v, :value), normal_vertices(g))
        first = M*aᵗ

        # (2)
        second = zeros(vertices_count)
        for vᵢ in normal_vertices(g)
            i = v_map[vᵢ]
            for interior in triangles_with_vertex(g, vᵢ)
                a, b, c = map(v -> coords(g, v), interior_vertices(g, interior))

                # Part that calculates diffusion
                hx = (max(x(a), x(b), x(c)) - min(x(a), x(b), x(c))) / 4
                hy = (max(y(a), y(b), y(c)) - min(y(a), y(b), y(c))) / 4
                xs, ys = center_point([a,b,c])[1:2]
                u = approx_function(g, interior)
                ∂u∂x = (u([xs + hx, ys]) - u([xs - hx, ys])) / (2 * hx)
                ∂u∂y = (u([xs, ys + hy]) - u([xs, ys - hy])) / (2 * hy)
                e = pyramid_function(g, interior, vᵢ)
                ∂e∂x = (e([xs + hx, ys]) - e([xs - hx, ys])) / (2 * hx)
                ∂e∂y = (e([xs, ys + hy]) - e([xs, ys - hy])) / (2 * hy)
                area = projection_area(g, interior)

                # Part that includes terrain to calculatin
                z_center = (z(a) + z(b) + z(c)) / 3.0
                k = γ * ((u([xs, ys])^α) / (abs(z_center + u([xs, ys])))^β)

                second[i] += k * (∂u∂x * ∂e∂x + ∂u∂y * ∂e∂y) * area
            end
            second[i] = -dt * second[i]
        end

        # 3
        third = zeros(vertices_count)
        for interior in interiors(g)
            for vᵢ in interior_vertices(g, interior)
                i = v_map[vᵢ]
                area = projection_area(g, interior)
                xs, ys = center_point(g, interior)[1:2]
                third[i] += f(xs, ys) * (1/3) * area
            end
        end
        third *= dt

        RHS = first + second + third
        aᵗ⁺¹ = inv_M * RHS
        # aᵗ⁺¹ has values close to 0 (ex. 1e-10) and sqrt doesn't work
        aᵗ⁺¹ = map(x -> x < 0.0 ? 0.0 : x, aᵗ⁺¹)
        result = vcat(result, aᵗ⁺¹')
        set_values!(g, aᵗ⁺¹)
    end

    result
end

end
