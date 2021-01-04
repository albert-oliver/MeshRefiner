using ..Utils

using MetaGraphs
using LightGraphs

function check_p6(g, center)
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

    if isnothing(hA) || isnothing(hB) || isnothing(hC) || hA == vA || hB == vB || hC == vC
        return nothing
    end

    lA = distance(g, vB, hA) + distance(g, vC, hA)
    lB = distance(g, vA, hB) + distance(g, vC, hB)
    lC = distance(g, vA, hC) + distance(g, vB, hC)
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

    L1 = distance(g, v1, h1)
    L2 = distance(g, h1, v2)
    L3 = distance(g, v2, h2)
    L4 = distance(g, h2, v3)
    L5 = distance(g, v3, h3)
    L6 = distance(g, h3, v1)

    if (L1 + L2) >= (L3 + L4) && (L1 + L2) >= (L5 + L6)
        return v1, v2, v3, h1, h2, h3
    end
    return nothing
end

function transform_p6!(g, center)
    mapping = check_p6(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h1, h2, h3 = mapping

    set_prop!(g, h1, :type, "vertex")

    add_meta_edge!(g, v3, h1, false)

    add_interior!(g, v1, h1, v3, false)
    add_interior!(g, h1, v2, v3, false)

    rem_vertex!(g, center)

    return true
end
