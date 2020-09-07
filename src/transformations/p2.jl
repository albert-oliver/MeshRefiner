function check_P2(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = interior_vertices(g, center)

    vA = vertexes[1]
    vB = vertexes[2]
    vC = vertexes[3]

    lA = distance(g, vA, vB)
    lB = distance(g, vB, vC)
    lC = distance(g, vC, vA)
    max = maximum([lA, lB, lC])

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h = nothing

    if max == lA
        v1 = vA
        v2 = vB
        v3 = vC
    elseif max == lB
        v1 = vB
        v2 = vC
        v3 = vA
    else
        v1 = vC
        v2 = vA
        v3 = vB
    end

    h = get_hanging_node_between(g, v1, v2)

    if isnothing(h)
        return nothing
    end


    if !has_edge(g, v1, v3) ||
       !has_edge(g, v2, v3)
        return nothing
    end

    L1 = distance(g, v1, h)
    L2 = distance(g, v2, h)
    L3 = distance(g, v2, v3)
    L4 = distance(g, v1, v3)

    if (L1+L2) >= L3 && (L1+L2) >= L4
        return v1, v2, v3, h
    end
    return nothing
end

function transform_P2!(g, center)
    mapping = check_P2(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h = mapping

    set_prop!(g, h, :type, "vertex")

    add_meta_edge!(g, h, v3, false)

    add_interior!(g, v1, v3, h, false)
    add_interior!(g, v2, v3, h, false)

    rem_vertex!(g, center)

    return true
end
