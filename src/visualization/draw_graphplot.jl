using Colors
using Printf
using GraphPlot

"""
    draw_graphplot(g, vid=false)

Draws 2D view of graph using `GraphPlot.jl`.

Not recommended for large graphs.

If `vid` (vertex id) is set to true each vertex is labeled after it's id. If not
label represents vertex type ('V', 'H', or 'I')
"""
function draw_graphplot(g::MeshGraph; vid=false, edge_lengths=false)
    function position_layout(sub_graph)
        x:: Array{Float64} = []
        y:: Array{Float64} = []
        for v in 1:nv(g)
            if is_interior(g, v)
                neigh = interiors_vertices(g, v)
                center = center_point([xyz(g, neigh[1]), xyz(g, neigh[2]), xyz(g, neigh[3])])
                push!(x, center[1])
                push!(y, center[2])
            else
                push!(x, xyz(g, v)[1])
                push!(y, xyz(g, v)[2])
            end
        end
        return x, y
    end
    # position_layout(g) = map((v) -> get_prop(g, v, :x), vertices(g)), map((v) -> get_prop(g, v, :y), vertices(g))

    if vid
        labels = 1:nv(g)
    else
        label_map = Dict(VERTEX => 'V', HANGING => 'H', INTERIOR => 'I')
        labels = map(v -> label_map[get_type(g, v)], 1:nv(g))
    end


    edge_labels = []
    if edge_lengths
        for (v1, v2) in all_edges(g)
            if is_ordinary_edge(g, v1, v2)
                push!(edge_labels, @sprintf("%.2f", edge_length(g, v1, v2)))
            else
                push!(edge_labels, "")
            end
        end
    end

    edge_colors = []
    edge_width = []
    for (v1, v2) in all_edges(g)
        if !is_ordinary_edge(g, v1, v2)
            push!(edge_colors, colorant"yellow")
            push!(edge_width, 1.0)
        elseif is_on_boundary(g, v1, v2)
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 3.0)
        else
            push!(edge_colors, colorant"lightgray")
            push!(edge_width, 1.0)
        end
    end

    vertex_size = []
    vertex_colors = []
    for v in 1:nv(g)
        if is_interior(g, v)
            push!(vertex_size, 1.0)
            if should_refine(g, v)
                push!(vertex_colors, colorant"orange")
            else
                push!(vertex_colors, colorant"yellow")
            end
        elseif is_vertex(g, v)
            push!(vertex_size, 1.0)
            push!(vertex_colors, colorant"lightgray")
        else
            push!(vertex_size, 1.0)
            push!(vertex_colors, colorant"gray")
        end
    end

    gplot(g.graph,
        layout=position_layout,
        nodelabel=labels,
        nodefillc=vertex_colors,
        edgelabel=edge_labels,
        edgestrokec=edge_colors,
        edgelinewidth=edge_width,
        nodesize=vertex_size)
end
