function check_P3(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = neighbors(g, center)

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h = nothing
    for i in 0:2
        v1 = vertexes[i+1]
        v2 = vertexes[(i+1)%3+1]
        v3 = vertexes[(i+2)%3+1]
        h = get_hanging_node_between(g, v1, v2)
        if !isnothing(h)
            break
        end
    end
    if isnothing(h)
        return nothing
    end

    if !has_edge(g, v1, v3) ||
       !has_edge(g, v2, v3)
        return nothing
    end

    L1 = get_prop(g, v1, h, :length)
    L2 = get_prop(g, v2, h, :length)
    L3 = get_prop(g, v2, v3, :length)
    L4 = get_prop(g, v1, v3, :length)

    if (L1+L2) >= L3 && (L1+L2) >= L4
        return v1, v2, v3, h
    end
    return nothing
end

function transform_P3!(g, center)
    mapping = check_P3(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3, h = mapping

    set_prop!(g, h, :type, "vertex")

    add_meta_edge!(g, h, v3, false)

    add_interior!(g, v1, v3, h, false)
    add_interior!(g, v2, v3, h, false)

    rem_vertex!(g, center)
end
