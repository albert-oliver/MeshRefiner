function check_P4(g, center)
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

    if count(x -> isnothing(x), [hA, hB, hC]) != 1 # Return if we don't have two hanging nodes
        return nothing
    end

    if !isnothing(hA)
        if !isnothing(hB)
            v1 = vB
            v2 = vC
            v3 = vA
            h1 = hA
            h2 = hB
        else # hA and hC
            v1 = vA
            v2 = vB
            v3 = vC
            h1 = hC
            h2 = hA
        end
    else # hA is nothing so that leaves hB and hC as hanging nodes
        v1 = vC
        v2 = vA
        v3 = vB
        h1 = hB
        h2 = hC
    end

    if !has_edge(g, v1, v3)
        return nothing
    end

    L1 = distance(g, v1, h1)
    L2 = distance(g, h1, v2)
    L3 = distance(g, v2, h2)
    L4 = distance(g, h2, v3)
    L5 = distance(g, v1, v3)

    if (L1 + L2) >= (L3 + L4) && (L1 + L2) >= L5
        return v1, v2, v3, h1, h2
    elseif (L3 + L4) >= (L1 + L2) && (L3 + L4) >= L5
        return v3, v2, v1, h2, h1
    end
    return nothing
end

function transform_P4!(g, center)
    mapping = check_P4(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h1, h2 = mapping

    add_meta_edge!(g, v3, h1, false)
    set_prop!(g, h1, :type, "vertex")

    add_interior!(g, v1, h1, v3, false)
    add_interior!(g, h1, v2, v3, false)

    rem_vertex!(g, center)

    return true
end
