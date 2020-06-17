function check_P9(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = neighbors(g, center)

    vA = nothing
    vB = nothing
    vC = nothing
    hA = nothing
    hB = nothing
    hC = nothing

    vA = vertexes[1]
    vB = vertexes[2]
    vC = vertexes[3]
    hA = get_hanging_node_between(g, vB, vC)
    hB = get_hanging_node_between(g, vA, vC)
    hC = get_hanging_node_between(g, vA, vB)

    if isnothing(hA) || isnothing(hB) || isnothing(hC)
        return nothing
    end

    lA = get_prop(g, vB, hA, :length) + get_prop(g, vC, hA, :length)
    lB = get_prop(g, vA, hB, :length) + get_prop(g, vC, hB, :length)
    lC = get_prop(g, vA, hC, :length) + get_prop(g, vB, hC, :length)
    max = maximum([lA, lB, lC])

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h1 = nothing
    h2 = nothing
    h3 = nothing

    if max == lA
        v1 = vB
        v2 = vC
        v3 = vA
        h1 = hA
        h2 = hB
        h3 = hB
    elseif max == lB
        v1 = vC
        v2 = vA
        v3 = vB
        h1 = hB
        h2 = hC
        h3 = hA
    elseif max == lC
        v1 = vA
        v2 = vB
        v3 = vC
        h1 = hC
        h2 = hA
        h3 = hB
    else
        return nothing
    end

    L1 = get_prop(g, v1, h1, :length)
    L2 = get_prop(g, h1, v2, :length)
    L3 = get_prop(g, v2, h2, :length)
    L4 = get_prop(g, h2, v3, :length)
    L5 = get_prop(g, v3, h3, :length)
    L6 = get_prop(g, h3, v1, :length)

    if (L1 + L2) >= (L3 + L4) && (L1 + L2) >= (L5 + L6)
        return v1, v2, v3, h1, h2, h3
    end
    return nothing
end

function transform_P9!(g, center)
    mapping = check_P9(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3, h1, h2, h3 = mapping

    set_prop!(g, h1, :type, "vertex")

    add_meta_edge!(g, v3, h1, false)

    add_interior!(g, v1, h1, v3, false)
    add_interior!(g, h1, v2, v3, false)

    rem_vertex!(g, center)
end
