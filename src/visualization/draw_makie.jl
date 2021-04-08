using ..Utils

using GLMakie
using MetaGraphs
using LightGraphs

"""
    draw_makie(g, wireframe=false, include_fun=false, transparent_fun=false)

Draws 3D view of graph using `Makie.jl`

It doesn't contain any interior vertices or labels (for clarity as graphs can
be quite big).
"""
function draw_makie(g; wireframe=false, include_fun=false, transparent_fun=true)
    # edges
    src_dest = map(e -> [e.src, e.dst], edges(g))
    is_proper(x) = !is_interior(g, x[1]) & !is_interior(g, x[2])
    not_interior = filter(is_proper, src_dest)
    list = vcat(not_interior...)
    coordinates = map(v -> coords(g, v), list)
    edge_coords = map(x -> Point3f0(x), coordinates)

    # To force 3D view
    scene = scatter([0.0, 0.5], [0.0, 0.5], [0.0, 0.5], markersize=0.1)

    linesegments!(edge_coords)

    # faces
    if !wireframe
        vertices, faces = terrain_mesh(g)
        mesh!(vertices, faces, color=:lightgrey, shading=true)
    end

    # function
    if !wireframe & include_fun
        vertices, faces = function_mesh(g)
        mesh!(vertices, faces, color=:lightblue,
            shading=!transparent_fun, transparency=transparent_fun)
    end

    scene
end
