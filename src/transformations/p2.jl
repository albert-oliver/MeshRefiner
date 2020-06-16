function check_P2(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    elseif !get_prop(g, center, :refine)
        return nothing
    end

    vertexes = neighbors(g, center)

    if !has_edge(g, vertexes[1], vertexes[2]) ||
       !has_edge(g, vertexes[1], vertexes[3]) ||
       !has_edge(g, vertexes[2], vertexes[3])
        return nothing
    end

    for i in 0:2
        v1 = vertexes[i+1]
        v2 = vertexes[(i+1)%3+1]
        v3 = vertexes[(i+2)%3+1]

        B1 = get_prop(g, v1, v2, :boundary)
        B2 = get_prop(g, v2, v3, :boundary)
        B3 = get_prop(g, v1, v3, :boundary)
        L1 = get_prop(g, v1, v2, :length)
        L2 = get_prop(g, v2, v3, :length)
        L3 = get_prop(g, v1, v3, :length)

        if !B1 && L1>=L2 && L1>=L3 && !((B2 && L2==L1) || B3 && L3==L1)
            return v1, v2, v3
        end
    end
    return nothing
end

function transform_P2!(g, center)
    mapping = check_P2(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    B1 = get_prop(g, v1, v2, :boundary)
    L1 = get_prop(g, v1, v2, :length)

    rem_edge!(g, v1, v2)

    v4 = add_hanging!(g, (p1[:x] + p2[:x])/2, (p1[:y] + p2[:y])/2, (p1[:z] + p2[:z])/2)

    add_meta_edge!(g, v4, v1, B1, L1/2)
    add_meta_edge!(g, v4, v2, B1, L1/2)
    add_meta_edge!(g, v4, v3, false)

    add_interior!(g, v1, v3, v4, false)
    add_interior!(g, v2, v3, v4, false)

    rem_vertex!(g, center)
end
