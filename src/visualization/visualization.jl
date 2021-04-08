"Module responsible for visualiztion of graphs"
module Visualization

using ..Utils

using MetaGraphs

export draw_makie, draw_graphplot, terrain_mesh, function_mesh

"""
    sort_cclockwise(ids, coords)

Sort points counter-clockwise. Return sorted `ids`
- `ids` is array of vertex ids
- `coords` is matrix where each row looks like: `[x, y, ...]`
"""
function sort_cclockwise(ids::Array{<:Integer}, coords::Matrix)
    center = center_point(coords)
    vectors = coords .- center
    angle = [atan(y, x) for (x, y) in eachrow(vectors[:, [1,2]])]
    ids[sortperm(angle)]
end

"""
    custom_z_mesh(g, z_fun, face_filter)

Return tuple `(vertices, faces)` with mesh representing terrain.
- `vertices` is matrix where each row is `x`, `y` and `z` coordinates of vertex
- `faces` is matrix where each row is three vertex indexes

# Arguments
- `g`: graph representing mesh
- `z_fun(g, v)`: function that calculates `z` coordinate of vertex based on
graph `g` and its id `v`.
- `face_filter(g, vs)`: function used to filter faces. `vs` is array of three
vertex ids.
"""
function custom_z_mesh(g, z_fun, face_filter)
    vmap = vertex_map(g)
    vmapf(x) = vmap[x]

    xyz(g, v) = [x(g, v), y(g, v), z_fun(g, v)]
    vertices = hcat([xyz(g, v) for v in normal_vertices(g)]...)'

    triangles = [interior_vertices(g, i) for i in interiors(g)]
    sorted = map(vs -> sort_cclockwise(vs, vertices[vmapf.(vs), :]), triangles)
    pa_filter(x) = face_filter(g, x)
    filtered_triangles = filter(pa_filter, sorted)
    matrix_triangles = hcat(filtered_triangles...)'
    faces = map(vmapf, matrix_triangles)

    (vertices, faces)
end

"""
    terrain_mesh(g)

Return tuple `(vertices, faces)` with mesh representing terrain.

- `vertices` is matrix where each row is `x`, `y` and `z` coordinates of vertex
- `faces` is matrix where each row is three vertex indexes
"""
function terrain_mesh(g)
    custom_z_mesh(g, (g, v) -> z(g, v), (g, vs) -> true)
end

"""
    function_mesh(g)

Return tuple `(vertices, faces)` with mesh representing approximated function
- `vertices` is matrix where each row is `x`, `y` and `z` coordinates of vertex.
where `z` is in fact `z` coordinate of vertex in graph + its `:value` property
- `faces` is matrix where each row is three vertex indexes

No face is generated if all vertices of triangle have `:value` property equal
to 0.
"""
function function_mesh(g)
    face_filter(g, vs) = !([get_prop(g, v, :value) for v in vs] ≈ [0.0, 0.0, 0.0])
    vs, f = custom_z_mesh(g, (g, v) -> get_prop(g, v, :value) + z(g, v), face_filter)
    (vs, f)
end

include("draw_makie.jl")
include("draw_graphplot.jl")

end
