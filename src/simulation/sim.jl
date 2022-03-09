"Modul that is responsible for all simulations on mesh"
module Simulation

export simulate!

using LinearAlgebra
using SparseArrays

using ..Utils
using ..HyperGraphs

"""
    common_triangles(h, i, j)

Return common triangles of vertices `i` and `j`. Common traingles are all
triangles with both `i` and `j` as its vertices.
"""
function common_triangles(g, i, j)
    intersect(interior_neighbors(g, i), interior_neighbors(g, j))
end

"Return interiors of all traingles that have `i` as one of thair vertices."
function triangles_with_vertex(g, i)
    filter(v -> is_interior(g, v), neighbors(g, i))
end

"""
    rel_triangle_ϵ(g, interior)

Caluculate ϵ realtive to traingle size such that point `(xs ± ϵ, ys ± ϵ)` is
inside triangle, where `(xs, ys)` is center of triangle.

Triangle is represented by `interior` in graph `g.`
"""
function rel_triangle_ϵ(g, interior)
    a, b, c = map(v -> xyz(g, v), interiors_vertices(g, interior))
    hx = (max(a[1], b[1], c[1]) - min(a[1], b[1], c[1])) / 4
    hy = (max(a[2], b[2], c[2])- min(a[2], b[2], c[2])) / 4
    min(hx, hy)
end

"""
    gradient(fun; ϵ=10e-3)

Caluculate approximate gradient of 2-dimensional function `f(vector)` in point
`point`.

See Also: [`approx_function`](@ref)
"""
function gradient(f, point; ϵ=10e-3)
    xs, ys = point
    ∂f∂x = (f([xs + ϵ, ys]) - f([xs - ϵ, ys])) / (2.0 * ϵ)
    ∂f∂y = (f([xs, ys + ϵ]) - f([xs, ys - ϵ])) / (2.0 * ϵ)
    [∂f∂x, ∂f∂y]
end

"""
    gradient_norm(g)

Compute L^2 norm of gradient over entire mesh `g`

See Also: [`gradient`](@ref)
"""
function gradient_norm(g)
    interiors_vector = collect(enumerate(interiors(g)))
    integrals = zeros(length(interiors_vector))
    Threads.@threads for (i, interior) in interiors_vector
        value_func(g, v) = get_value(g, v) + get_elevation(g, v)
        f = approx_function(g, interior, value_func)
        center = center_point(g, interior)[1:2]
        ϵ = rel_triangle_ϵ(g, interior)
        grad = gradient(f, center; ϵ=ϵ)
        area = projection_area(g, interior)
        integrals[i] = (grad[1]^2 + grad[2]^2) * area
    end
    sqrt(sum(integrals))
end

"""
    ee_matrix(g)

Calculate matrix NxN, where N is number of normal vertices in graphs `g` and:

``M_{ij} = \\int e_i \\cdot e_j``

Where ``e_i`` is a pyramid-like function with summit with value 1 in vertex ``i``,
that goes down to 0 in neighbour vertices.
"""
function ee_matrix(g)
    v_map = vertex_map(g)
    vertices_count = length(v_map)
    I::Array{Int64} = []; J::Array{Int64} = []; V::Array{Float64} = [];
    for interior in interiors(g)
        area = projection_area(g, interior)
        for vᵢ in interiors_vertices(g, interior)
            for vⱼ in interiors_vertices(g, interior)
                i = v_map[vᵢ]
                j = v_map[vⱼ]
                v = i == j ? (1/6) * area : (1/12) * area
                push!(I, i)
                push!(J, j)
                push!(V, v)
            end
        end
    end
    sparse(I, J, V, vertices_count, vertices_count)
end

"Calculate 'physics' of water in graph `g`"
function calculate_physics(g, dt, aᵗ⁻¹, earth_acc)
    # norm_∇u_abs = gradient_norm(g)
    v_map = vertex_map(g)
    physics = zeros(length(v_map))

    Threads.@threads for vᵢ in collect(normal_vertices(g))
        i = v_map[vᵢ]
        for interior in triangles_with_vertex(g, vᵢ)
            xs, ys = center_point(g, interior)[1:2]
            area = projection_area(g, interior)

            # Part that calculates diffusion
            ϵ = rel_triangle_ϵ(g, interior)
            function value_func(g, v)
                elev = get_elevation(g, v)
                j = v_map[v]
                aᵗ⁻¹[j] + elev
            end
            # value_func(g, v) = get_value(g, v) + get_elevation(g, v)
            u = approx_function(g, interior, value_func)
            ∇u = gradient(u, [xs, ys]; ϵ=ϵ)
            e = pyramid_function(g, interior, vᵢ)
            ∇e = gradient(e, [xs, ys]; ϵ=ϵ)

            only_water_value_func(g, v) = aᵗ⁻¹[v_map[v]]
            u_min_z = approx_function(g, interior, only_water_value_func)
            # Part that includes terrain to calculatin
            # k = γ * ((u_min_z([xs, ys])^α) / norm_∇u_abs^β)
            k = earth_acc * u_min_z([xs, ys])

            physics[i] += k * dot(∇u, ∇e) * area
        end
    end
    physics *= (-dt^2)
    physics
end

"Calculate water source (f>0) or drain (f<0)."
function calculate_source(g, dt, f)
    v_map = vertex_map(g)
    source = zeros(length(v_map))
    for interior in interiors(g)
        area = projection_area(g, interior)
        xs, ys = center_point(g, interior)[1:2]
        value = f(xs, ys) * (1/3) * area
        for vᵢ in interiors_vertices(g, interior)
            i = v_map[vᵢ]
            source[i] += value
        end
    end
    source *= dt
    source
end

function get_initial_values(g, initial_values)::Matrix{Float64}
    result = initial_values
    if isnothing(result)
        result = map(v -> get_value(g, v), normal_vertices(g))
    end
    if typeof(result) <: AbstractVector
        result = transpose(hcat(result, result))
    elseif typeof(result) <: AbstractMatrix && size(result, 1) == 1
        result = vcat(result, result)
    end
    if size(result, 2) != length(vertex_map(g))
        throw(DomainError("Argument initial_values is different size than number of graph vertices"))
    end
    result
end

function disable_matrix_vertex!(M, i)
    for j in 1:size(M, 2)
        M[i, j] = 0
    end
    M[i, i] = 1
end

function disable_matrix_if!(M, g, condtion_fun)
    v_map = vertex_map(g)
    for v in normal_vertices(g)
        if condtion_fun(v)
            i = v_map[v]
            disable_matrix_vertex!(M, i)
        end
    end
end

function disable_rhs_if!(RHS, g, condtion_fun)
    v_map = vertex_map(g)
    for v in normal_vertices(g)
        if condtion_fun(v)
            i = v_map[v]
            elev = get_elevation(g, v)
            RHS[i] = elev < 0 ? -elev : 0
        end
    end
end

"""
    simulate!(g, steps, dt, f; γ=1.0, α=5/3, β=0.5)

Perform flood simulation on previously generated mesh `g`. Length of each time
step is `dt`.

Note that graph `g` should have been adapted to function representing starting
water level using `adapt_fun!`.
"""
function simulate!(
    g,
    steps,
    dt,
    f;
    initial_values = nothing,
    c1 = 1.0,
    c2 = 1.0,
    γ = 1.0,
    α = 5 / 3,
    β = 0.5,
    ϵ = 0.0,
    earth_acc = 9.81,
    disable_condition = (v) -> false,
    log_every=nothing
)
    result = get_initial_values(g, initial_values)
    v_map = vertex_map(g)

    # This matrix doesn't change
    M = ee_matrix(g)
    disable_matrix_if!(M, g, disable_condition)
    F = lu(M)

    for step = 1:steps

        if !isnothing(log_every) && step % log_every == 0
            println("Step: ", step)
        end

        # RHS
        # (1)
        aᵗ⁻² = result[step, :]
        aᵗ⁻¹ = result[step+1, :]
        previous_step = M * (aᵗ⁻¹ + c1*(aᵗ⁻¹ - aᵗ⁻²))

        # (2)
        physics = calculate_physics(g, dt, aᵗ⁻¹, earth_acc)

        # (3)
        source = calculate_source(g, dt, f)

        RHS = previous_step + c2*physics + source
        disable_rhs_if!(RHS, g, disable_condition)
        aᵗ = F \ RHS
        # aᵗ has negative values close to 0 (ex. -1e-10) and sqrt doesn't work
        aᵗ = map(x -> x < ϵ ? 0.0 : x, aᵗ)
        result = vcat(result, aᵗ')
        set_all_values!(g, aᵗ)
    end

    result
end

end
