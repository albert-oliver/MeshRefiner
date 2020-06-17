function check_P4(g, center)
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
        if !isnothing(h) && h != v3
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

    if !get_prop(g, v1, v3, :boundary)
        if !get_prop(g, v2, v3, :boundary)
            return nothing
        else
            tmp = v1
            v1 = v2
            v2 = tmp
        end
    end

    L1 = get_prop(g, v1, h, :length)
    L2 = get_prop(g, v2, h, :length)
    L3 = get_prop(g, v2, v3, :length)
    L4 = get_prop(g, v1, v3, :length)

    if L4 > (L1+L2) && L4 >= L3
        return v1, v2, v3, h
    end
    return nothing
end

function transform_P4!(g, center)
    mapping = check_P4(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h = mapping
    p1 = props(g, v1)
    p3 = props(g, v3)

    L4 = get_prop(g, v1, v3, :length)
    B4 = get_prop(g, v1, v3, :boundary)

    v5 = add_meta_vertex!(g, (p1[:x] + p3[:x])/2, (p1[:y] + p3[:y])/2, (p1[:z] + p3[:z])/2)

    rem_edge!(g, v1, v3)

    add_meta_edge!(g, v1, v5, B4, L4/2)
    add_meta_edge!(g, v3, v5, B4, L4/2)
    add_meta_edge!(g, v2, v5, false)

    add_interior!(g, v1, v2, v5, false)
    add_interior!(g, v2, v5, v3, false)

    rem_vertex!(g, center)

    return true
end
