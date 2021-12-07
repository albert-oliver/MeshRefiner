using ..Utils

using GLMakie

"""
    draw_makie(g; wireframe=false, include_fun=false, transparent_fun=false, show_axis=false)

Draws 3D view of graph using `Makie.jl`

It doesn't contain any interior vertices or labels (for clarity as graphs can
be quite big).
"""
function draw_makie(g;
    wireframe=false, include_fun=false,
    transparent_fun=true, shading_fun=false, show_axis=false)

    # edges
    list = vcat(edges(g)...)
    coordinates = map(v -> xyz(g, v), list)
    edge_coords = map(x -> Point3f0(x), coordinates)

    # To force 3D view
    scene = scatter([0.0, 0.5], [0.0, 0.5], [0.0, 0.5],
        markersize=0.001, figure = (resolution = (1280, 720),), show_axis = show_axis)

    linesegments!(edge_coords)

    # faces
    if !wireframe
        vertices, faces = terrain_mesh(g)
        mesh!(vertices, faces, color=:lightgrey, shading=true)
    end

    # function
    if !wireframe & include_fun
        vertices, faces = function_mesh(g)
        if !isempty(faces)
            mesh!(vertices, faces, color=:lightblue,
                shading=shading_fun, transparency=transparent_fun)
        end
    end

    scene
end
