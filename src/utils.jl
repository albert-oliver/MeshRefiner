using Colors


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
    if has_edge(g, v1, v2)
        return nothing
    end
    nodes1 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v1))
    nodes2 = filter(v -> get_prop(g, v, :type) == "hanging", neighbors(g, v2))
    nodes = intersect(nodes1, nodes2)

    for node in nodes
        x1 = get_prop(g, v1, :x)
        y1 = get_prop(g, v1, :y)
        x2 = get_prop(g, v2, :x)
        y2 = get_prop(g, v2, :y)
        xh = get_prop(g, node, :x)
        yh = get_prop(g, node, :y)
        if xh == (x1+x2)/2.0 && yh ==(y1+y2)/2.0
            return node
        end
    end

    return nothing

    # TODO code below might not be working correctly
    # Above is possible fix
    # DELETE if true
    # if size(nodes, 1) < 1
    #     return nothing
    # end
    #
    # return nodes[1]
end

function add_meta_vertex!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "vertex")
    set_prop!(g, nv(g), :x, convert(Float64, x))
    set_prop!(g, nv(g), :y, convert(Float64, y))
    set_prop!(g, nv(g), :z, convert(Float64, z))
    return nv(g)
end

function add_hanging!(g, x, y, z)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "hanging")
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    return nv(g)
end

function add_interior!(g, v1, v2, v3, refine)
    add_vertex!(g)
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, refine)
    set_prop!(g, nv(g), :v1, v1)
    set_prop!(g, nv(g), :v2, v2)
    set_prop!(g, nv(g), :v3, v3)
    return nv(g)
end

interior_vertices(g, i) = [get_prop(g, i, :v1), get_prop(g, i, :v2), get_prop(g, i, :v3)]

function add_meta_edge!(g, v1, v2, boundary)
    add_edge!(g, v1, v2)
    set_prop!(g, v1, v2, :boundary, boundary)
end

distance(graph::AbstractMetaGraph, vertex_1::Integer, vertex_2::Integer) = cartesian_distance(props(graph, vertex_1), props(graph, vertex_2))

function cartesian_distance(p1, p2)
    # println("(x1-x2)^2: ", (convert(Float64, p1[:x])-convert(Float64, p2[:x]))^2)
    # println("(y1-y2)^2: ", (convert(Float64, p1[:y])-convert(Float64, p2[:y]))^2)
    # println("(z1-z2)^2: ", (convert(Float64, p1[:z])-convert(Float64, p2[:z]))^2)
    x1 = convert(Float64, p1[:x])
    x2 = convert(Float64, p2[:x])
    y1 = convert(Float64, p1[:y])
    y2 = convert(Float64, p2[:y])

    return sqrt(sum([(x1-x2)^2, (y1-y2)^2]))
end

x(graph::AbstractMetaGraph, vertex::Integer)::Float64 = get_prop(graph, vertex, :x)
y(graph::AbstractMetaGraph, vertex::Integer)::Float64 = get_prop(graph, vertex, :y)
z(graph::AbstractMetaGraph, vertex::Integer)::Float64 = get_prop(graph, vertex, :z)
