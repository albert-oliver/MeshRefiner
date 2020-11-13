function check_p3(g, center)
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
        h = hA
    elseif !isnothing(hB)
        h = hB
    else
        h = hC
    end

    lAB = distance(g, vA, vB)
    lBC = distance(g, vB, vC)
    lCA = distance(g, vC, vA)
    max = maximum([lAB, lBC, lCA])

    if max == lAB
        if h == hA
            v1 = vB
            v2 = vC
            v3 = vA
        elseif h == hB
            v1 = vA
            v2 = vC
            v3 = vB
        else
            return nothing
        end
    elseif max == lBC
        if h == hB
            v1 = vC
            v2 = vA
            v3 = vB
        elseif h == hC
            v1 = vB
            v2 = vA
            v3 = vC
        else
            return nothing
        end
    else # max == lCA
        if h == hA
            v1 = vC
            v2 = vB
            v3 = vA
        elseif h == hC
            v1 = vA
            v2 = vB
            v3 = vC
        else
            return nothing
        end
    end

    if !has_edge(g, v1, v3) ||
       !has_edge(g, v2, v3)
        return nothing
    end

    L4 = distance(g, v1, h)
    L5 = distance(g, h, v2)
    L2 = distance(g, v2, v3)
    L3 = distance(g, v1, v3)
    B2 = get_prop(g, v2, v3, :boundary)
    B3 = get_prop(g, v1, v3, :boundary)
    HN1 = get_prop(g, v1, :type) == "hanging" ? true : false
    HN3 = get_prop(g, v3, :type) == "hanging" ? true : false

    if ((L3 > (L4 + L5)) && (L3 >= L2)) && (B3 ||
        ( !B3 && (!HN1 && !HN3) && (!(B2 && L2 == L3))) )
        return v1, v2, v3, h
    end
    return nothing
end

function transform_p3!(g, center)
    mapping = check_p3(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h = mapping
    p1 = props(g, v1)
    p3 = props(g, v3)

    B3 = get_prop(g, v1, v3, :boundary)

    v5 = add_meta_vertex!(g, (p1[:x] + p3[:x])/2, (p1[:y] + p3[:y])/2, (p1[:z] + p3[:z])/2)
    if !B3
        set_prop!(g, v5, :type, "hanging")
    end

    rem_edge!(g, v1, v3)

    add_meta_edge!(g, v1, v5, B3)
    add_meta_edge!(g, v3, v5, B3)
    add_meta_edge!(g, v2, v5, false)

    add_interior!(g, v1, v2, v5, false)
    add_interior!(g, v2, v5, v3, false)

    rem_vertex!(g, center)

    return true
end
