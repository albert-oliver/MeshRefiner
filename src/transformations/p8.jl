function check_P8(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = interior_vertices(g, center)

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h1 = nothing
    h2 = nothing

    for i in 0:2
        v1 = vertexes[i+1]
        v2 = vertexes[(i+1)%3+1]
        v3 = vertexes[(i+2)%3+1]
        h1 = get_hanging_node_between(g, v1, v2)
        h2 = get_hanging_node_between(g, v2, v3)
        if isnothing(h1) || isnothing(h2) || h1 == v3 || h2 == v1
            break
        end
    end

    if isnothing(h1) || isnothing(h2)
        return nothing
    end

    if !has_edge(g, v1, v3)
        return nothing
    end

    L1 = distance(g, v1, h1)
    L2 = distance(g, h1, v2)
    L3 = distance(g, v2, h2)
    L4 = distance(g, h2, v3)
    L5 = distance(g, v1, v3)
    B5 = get_prop(g, v1, v3, :boundary)

    if !B5 && L5 > (L1 + L2) && L5 > (L3+L4)
        return v1, v2, v3, h1, h2
    end
    return nothing
end

function transform_P8!(g, center)
    mapping = check_P8(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h1, h2 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    p3 = props(g, v3)

    B5 = get_prop(g, v1, v3, :boundary)

    h3 = add_hanging!(g, (p1[:x] + p3[:x])/2, (p1[:y] + p3[:y])/2, (p1[:z] + p3[:z])/2)

    add_meta_edge!(g, v1, h3, B5)
    add_meta_edge!(g, h3, v3, B5)
    add_meta_edge!(g, v2, h3, false)

    add_interior!(g, v1, v2, h3, false)
    add_interior!(g, h3, v2, v3, false)

    rem_edge!(g, v1, v3)
    rem_vertex!(g, center)

    return true
end
