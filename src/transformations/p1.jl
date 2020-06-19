function check_P1(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    elseif !get_prop(g, center, :refine)
        return nothing
    end

    vertexes = interior_vertices(g, center)

    if !has_edge(g, vertexes[1], vertexes[2]) ||
       !has_edge(g, vertexes[1], vertexes[3]) ||
       !has_edge(g, vertexes[2], vertexes[3])
        return nothing
    end

    la = distance(g, vertexes[1], vertexes[2])
    lb = distance(g, vertexes[2], vertexes[3])
    lc = distance(g, vertexes[3], vertexes[1])
    longest = maximum([la, lb, lc])

    if longest == la
        v1 = vertexes[1]
        v2 = vertexes[2]
        h = vertexes[3]
    elseif longest == lb
        v1 = vertexes[2]
        v2 = vertexes[3]
        h = vertexes[1]
    else
        v1 = vertexes[1]
        v2 = vertexes[3]
        h = vertexes[2]
    end

    B1 = get_prop(g, v1, v2, :boundary)
    L1 = distance(g, v1, v2)
    L2 = distance(g, h, v1)
    L3 = distance(g, h, v2)

    if B1 && (L1 >= L2) && (L1 >= L3)
        return h, v1, v2
    end
end

function transform_P1!(g, center)
    mapping = check_P1(g, center)
    if isnothing(mapping)
        return false
    end

    h, v1, v2 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    B1 = get_prop(g, v1, v2, :boundary)
    L1 = distance(g, v1, v2)

    rem_edge!(g, v1, v2)

    v4 = add_meta_vertex!(g, (p1[:x] + p2[:x])/2, (p1[:y] + p2[:y])/2, (p1[:z] + p2[:z])/2)

    add_meta_edge!(g, v4, v1, B1)
    add_meta_edge!(g, v4, v2, B1)
    add_meta_edge!(g, v4, h, false)

    add_interior!(g, v1, h, v4, false)
    add_interior!(g, v2, h, v4, false)

    rem_vertex!(g, center)

    return true
end
