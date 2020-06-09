using Colors
using GraphPlot
using Makie
using Printf

function center_point(points)
    mean = [0.0, 0.0, 0.0]
    for point in points
        mean[1] += point[:x]
        mean[2] += point[:y]
        mean[3] += point[:z]
    end
    mean[1] /= size(points, 1)
    mean[2] /= size(points, 1)
    mean[3] /= size(points, 1)
    return mean
end

function get_hanging_node_between(g, v1, v2)
    for neigh_1 in inneighbors(g, v1)
        if get_prop(g, neigh_1, :type) == "hanging"
            for neigh_2 in inneighbors(g, neigh_1)
                if neigh_2 == v2
                    return neigh_1
                end
            end
        end
    end
    return nothing
end

distance(graph::AbstractMetaGraph, vertex_1::Integer, vertex_2::Integer) = cartesian_distance(props(graph, vertex_1), props(graph, vertex_2))

cartesian_distance(p1, p2) = sqrt(sum(((p1[:x]-p2[:x])^2, (p1[:y]-p2[:y])^2, (p1[:z]-p2[:z])^2)))

function draw_graph(g)
    position_layout(g) = map((v) -> get_prop(g, v, :x), vertices(g)), map((v) -> get_prop(g, v, :y), vertices(g))

    labels = map((vertex) -> uppercase(get_prop(g, vertex, :type)[1]), 1:nv(g))

    edge_labels = []
    for edge in edges(g)
        if has_prop(g, edge, :length)
            push!(edge_labels, @sprintf("%.2f", get_prop(g, edge, :length)))
        else
            push!(edge_labels, "")
        end
    end

    edge_colors = []
    edge_width = []
    for edge in edges(g)
        if !has_prop(g, edge, :boundary)
            push!(edge_colors, colorant"yellow")
            push!(edge_width, 1.0)
        elseif get_prop(g, edge, :boundary)
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 3.0)
        else
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 1.0)
        end
    end

    vertex_colors = []
    for vertex in 1:nv(g)
        if get_prop(g, vertex, :type) == "interior"
            if get_prop(g, vertex, :refine)
                push!(vertex_colors, colorant"orange")
            else
                push!(vertex_colors, colorant"yellow")
            end
        elseif get_prop(g, vertex, :type) == "vertex"
                push!(vertex_colors, colorant"lightgray")
        else
                push!(vertex_colors, colorant"gray")
        end
    end

    gplot(g,
        layout=position_layout,
        nodelabel=labels,
        nodefillc=vertex_colors,
        edgelabel=edge_labels,
        edgestrokec=edge_colors,
        edgelinewidth=edge_width)
end

x(graph::AbstractMetaGraph, vertex::Integer) = get_prop(g, vertex, :x)
y(graph::AbstractMetaGraph, vertex::Integer) = get_prop(g, vertex, :y)
z(graph::AbstractMetaGraph, vertex::Integer) = get_prop(g, vertex, :z)

function draw_makie(g)
    labels = map((vertex) -> uppercase(get_prop(g, vertex, :type)[1]), 1:nv(g))

    edge_labels = []
    for edge in edges(g)
        if has_prop(g, edge, :length)
            push!(edge_labels, @sprintf("%.2f", get_prop(g, edge, :length)))
        else
            push!(edge_labels, "")
        end
    end

    edge_colors = []
    edge_width = []
    for edge in edges(g)
        if !has_prop(g, edge, :boundary)
            push!(edge_colors, colorant"yellow")
            push!(edge_width, 1.0)
        elseif get_prop(g, edge, :boundary)
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 3.0)
        else
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 1.0)
        end
    end

    vertex_colors = []
    for vertex in 1:nv(g)
        if get_prop(g, vertex, :type) == "interior"
            if get_prop(g, vertex, :refine)
                push!(vertex_colors, colorant"orange")
            else
                push!(vertex_colors, colorant"yellow")
            end
        elseif get_prop(g, vertex, :type) == "vertex"
                push!(vertex_colors, colorant"lightgray")
        else
                push!(vertex_colors, colorant"gray")
        end
    end

    xs(graph::AbstractMetaGraph) = map((v) -> x(g, v), vertices(graph))
    ys(graph::AbstractMetaGraph) = map((v) -> y(g, v), vertices(graph))
    zs(graph::AbstractMetaGraph) = map((v) -> z(g, v), vertices(graph))

    scene = scatter(xs(g), ys(g), zs(g), color = :black, markersize = 0.1)
    # TODO: edges, proper coloring

    scene
end
