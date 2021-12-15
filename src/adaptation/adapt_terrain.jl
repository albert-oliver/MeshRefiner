using ..Utils
# using ..Transformations

using Statistics

struct BoundingBox
    min_x::Number
    max_x::Number
    min_y::Number
    max_y::Number
end

struct RefinementParameters
    ϵ::Number
    coastline_lower_bound::Number
    coastline_upper_bound::Number
    coastline_min_size::Number
end

function initial_graph_sphere(t::TerrainMap)::SphereGraph
    g = SphereGraph(100)
    add_vertex!(g, [y_min(t),  x_min(t)], real_elevation(t, x_min(t), y_min(t)))
    add_vertex!(g, [y_min(t), x_max(t)], real_elevation(t, x_min(t), y_max(t)))
    add_vertex!(g, [y_max(t), x_max(t)], real_elevation(t, x_max(t), y_max(t)))
    add_vertex!(g, [y_max(t),  x_min(t)], real_elevation(t, x_max(t), y_min(t)))
    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 3, 4; boundary=true)
    add_edge!(g, 4, 1; boundary=true)
    # diagonal
    add_edge!(g, 1, 3)
    add_interior!(g, 1, 2, 3)
    add_interior!(g, 1, 3, 4)
    return g
end

function initial_graph(t::TerrainMap)::FlatGraph
    g = FlatGraph()
    add_vertex!(g, [x_min(t),  y_min(t)], real_elevation(t, x_min(t), y_min(t)))
    add_vertex!(g, [x_min(t), y_max(t)], real_elevation(t, x_min(t), y_max(t)))
    add_vertex!(g, [x_max(t), y_max(t)], real_elevation(t, x_max(t), y_max(t)))
    add_vertex!(g, [x_max(t),  y_min(t)], real_elevation(t, x_max(t), y_min(t)))
    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 3, 4; boundary=true)
    add_edge!(g, 4, 1; boundary=true)
    # diagonal
    add_edge!(g, 1, 3)
    add_interior!(g, 1, 2, 3)
    add_interior!(g, 1, 3, 4)
    return g
end

"""
    point_in_triangle(p, M)
    point_in_triangle(p, t)

Is point `p` inside triangle represented as:
- matrix `M`, see [`barycentric_matrix`](@ref)
- Triangle `t`, see [`Triangle`](@ref)

Note that second method is ineffective when used repeatedly on the same
triangle.
"""
function point_in_triangle end

function point_in_triangle(p, M)
    bc = barycentric(M, p)
    return bc[1] > 0 && bc[2] > 0 && 1 - bc[1] - bc[2] > 0
end

function point_in_triangle(p, t::Triangle)
    M = barycentric_matrix(t)
    point_in_triangle(p, t, M)
end

"Return all indexes of matrix (field of `terrain`) that are inside triangle `t`"
function indexes_in_triangle(t::Triangle, terrain::TerrainMap)
    t_i = map(p -> point_to_index_coords(terrain, p[1], p[2]), t)

    bb = BoundingBox(
            minimum([t_i[1][1], t_i[2][1], t_i[3][1]]),
            maximum([t_i[1][1], t_i[2][1], t_i[3][1]]),
            minimum([t_i[1][2], t_i[2][2], t_i[3][2]]),
            maximum([t_i[1][2], t_i[2][2], t_i[3][2]])
        )

    M = barycentric_matrix(t_i)
    indexes = []
    for i in ceil(Int, bb.min_x):floor(Int, bb.max_x)
        for j in ceil(Int, bb.min_y):floor(Int, bb.max_y)
            if point_in_triangle([i, j], M)
                push!(indexes, [i, j])
            end
        end
    end

    return indexes
end

"""
Return iterator over pairs `(real, approx)` of all the points from `terrain`
inside traingle represented by `interior`, where `real` is value from `terrain`
and `approx` is approximated value in graph `g`
"""
function zipped_points_inside_triangle(g, interior, terrain)
    v1, v2, v3 = interiors_vertices(g, interior)
    triangle = (coords2D(g, v1), coords2D(g, v2), coords2D(g, v3))
    indexes = indexes_in_triangle(triangle, terrain)
    points = map(i -> index_to_point(terrain, i[1], i[2]), indexes)
    M = barycentric_matrix(triangle)
    points_br = map(p -> barycentric(M, p), points)

    function approx(p)
        get_elevation(g, v1) * p[1] +
        get_elevation(g, v2) * p[2] +
        get_elevation(g, v3) * (1 - p[1] - p[2])
    end
    approx_elev = map(approx, points_br)
    real_elev = map(i -> terrain.M[i[1], i[2]], indexes)

    return zip(real_elev, approx_elev)
end

"Return approximate error of traingle represented by interior `interior`. Error
is calculated as relative square error over all points from `terrain` iniside
triangle represented by `interior`."
function square_rel_error(g::HyperGraph, interior::Integer, terrain::TerrainMap)::Real
    real_elev, approx_elev = zipped_points_inside_triangle(g, interior, terrain)
    if isempty(real_elev)
        return 0.0
    end

    error = sum(map(x -> x^2, approx_elev - real_elev))
    error_rel = error / sum(map(x -> x^2, real_elev))

    return error_rel
end

"""
    square_rel_error_refinement_criterion(g, interior, terrain, ϵ)

Check if traingle should be refined based on relative square error. Return
`true` if error is greater than `ϵ`

See also: See also: [`height_difference_refinement_criterion`](@ref)
"""
function square_rel_error_refinement_criterion(g, interior, terrain, ϵ)
    error = square_rel_error(g, interior, terrain)
    return error > ϵ
end

"""
    height_difference_refinement_criterion(g, interior, terrain, ϵ)

Check if traingle should be refined based on height difference. If **any** of
the points in triangle has error greater than `ϵ` return `true`.

See also: See also: [`height_difference_refinement_criterion`](@ref)
"""
function height_difference_refinement_criterion(g, interior, terrain, ϵ)
    for (real, approx) in zipped_points_inside_triangle(g, interior, terrain)
        if abs(real - approx) > ϵ
            return true
        end
    end
    return false
end

function coastline_refinement_criterion(g, interior, terrain, params)

    lower_bound = params.coastline_lower_bound
    upper_bound = params.coastline_upper_bound

    vertices = interiors_vertices(g, interior)

    if (projection_area(g, interior) > params.coastline_min_size &&

        # All of these transtales into: not all the nodes above upper bound OR
        #                               not all the nodes below lower bound
        (
        (any([xyz(g, v)[3] <= upper_bound for v in vertices]) &&
         any([xyz(g, v)[3] > upper_bound for v in vertices]))
        ||
        (any([xyz(g, v)[3] <= lower_bound for v in vertices]) &&
         any([xyz(g, v)[3] > lower_bound for v in vertices]))
        ||
        any([lower_bound .<= xyz(g, v)[3] .<= upper_bound for v in vertices])
        )
        )
            return true
    end
    return false
end

"Mark all traingles where error is larger than `ϵ` for refinement."
function mark_for_refinement(g::HyperGraph, terrain::TerrainMap, params)::Array{Number, 1}
    to_refine = []
    for interior in interiors(g)

        if (height_difference_refinement_criterion(g, interior, terrain, params.ϵ) ||
              coastline_refinement_criterion(g, interior, terrain, params))
            push!(to_refine, interior)
        end
    end
    return to_refine
end

"Adjust elevations of all vertices to fit proper values."
function adjust_elevations!(g::HyperGraph, terrain::TerrainMap)
    for v in normal_vertices(g)
        x, y = coords2D(g, v)
        elev = real_elevation(terrain, x, y)
        set_elevation!(g, v, elev)
    end
end

"""
Scale all elevations in graph `g` to real values.

*Note* that it is called only *once* - after adaptation and graph
should *not* be adapted any further as it will not work properly.

Before calling this function all elevations are in range [0, 1].
Real life values cause overflow when calculating error for large triangles (as
it is relative error it requires division by sum of squeres of elevations).
"""
function scale_elevations!(g::HyperGraph, terrain)
    for v in normal_vertices(g)
        elev = get_elevation(g, v)
        set_elevation!(g, v, (elev - 1) * terrain.scale + terrain.offset)
    end
end
