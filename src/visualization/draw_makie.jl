using ..Utils

using Makie
using MetaGraphs
using LightGraphs

function draw_makie(g)
    labels = map((vertex) -> uppercase(get_prop(g, vertex, :type)[1]), 1:nv(g))

    edge_coords = Pair{Point{3,Float32},Point{3,Float32}}[]

    for edge in edges(g)
        p1 = edge.src
        p2 = edge.dst
        if get_prop(g, p1, :type) == "interior" || get_prop(g, p2, :type) == "interior"
            continue
        end
        push!(edge_coords, Point3f0(x(g, p1), y(g, p1), z(g, p1)) => Point3f0(x(g, p2), y(g, p2), z(g, p2)))
    end

    not_interior(g, v) = if get_prop(g, v, :type) == "interior" false else true end

    xs(graph::AbstractMetaGraph) = map((v) -> x(g, v), filter_vertices(graph, not_interior))
    ys(graph::AbstractMetaGraph) = map((v) -> y(g, v), filter_vertices(graph, not_interior))
    zs(graph::AbstractMetaGraph) = map((v) -> z(g, v), filter_vertices(graph, not_interior))

    scene = scatter(xs(g), ys(g), zs(g), color = :black, markersize = 0.1)
    linesegments!(scene, edge_coords)
    # TODO: proper coloring

    scene
end
