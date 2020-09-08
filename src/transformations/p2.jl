function check_P2(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = interior_vertices(g, center)

    vA = vertexes[1]
    vB = vertexes[2]
    vC = vertexes[3]
    hA = get_hanging_node_between(g, vB, vC)
    hB = get_hanging_node_between(g, vA, vC)
    hC = get_hanging_node_between(g, vA, vB)

    if count(x -> isnothing(x), [hA, hB, hC]) != 2 # Return if we don't have one hanging node
        return nothing
    end

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h = nothing

    if !isnothing(hA)
        v1 = vB
        v2 = vC
        v3 = vA
        h = hA
    elseif !isnothing(hB)
        v1 = vA
        v2 = vC
        v3 = vB
        h = hB
    else
        v1 = vA
        v2 = vB
        v3 = vC
        h = hC
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
