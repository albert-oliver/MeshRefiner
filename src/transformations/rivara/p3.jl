function check_p3(g::HyperGraph, center::Integer)
    if !is_interior(g, center)
        return nothing
    end

    vs = interiors_vertices(g, center)
    vA = vs[1]
    vB = vs[2]
    vC = vs[3]
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
    longest = maximum([lAB, lBC, lCA])

    if longest == lAB
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
    elseif longest == lBC
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
    else # longest == lCA
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
    B2 = is_on_boundary(g, v2, v3)
    B3 = is_on_boundary(g, v1, v3)
    HN1 = is_hanging(g, v1)
    HN3 = is_hanging(g, v3)

    if ((L3 > (L4 + L5)) && (L3 >= L2)) && (B3 ||
        ( !B3 && (!HN1 && !HN3) && (!(B2 && L2 == L3))) )
        return v1, v2, v3, h
    end
    return nothing
end

"""
    transform_p3!(g, center)

Run transgormation P3 on triangle represented by interior `center`.

One edge with hanging node that is not the longest edge.

```text
     v                v
    / \\              /|\\
   h   \\     =>     h | \\
  /     \\          /  |  \\
 v-------v        v---h---v
```

Conditions:
- Breaks *longest edge* (note that hanging node is not on it) if eiter is true:
    - It is on the boundary (`:boundary` property is set to `true`), **OR**
    - It's vertices are not hanging nodes **AND** other egde is not same
    length and on the boundary
"""
function transform_p3!(g::HyperGraph, center::Integer)
    mapping = check_p3(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h = mapping

    B3 = is_on_boundary(g, v1, v3)

    v5 = add_vertex!(g, (xyz(g, v1) + xyz(g, v3)) / 2.0)
    if !B3
        set_hanging!(g, v5, v1, v3)
    end

    rem_edge!(g, v1, v3)

    add_edge!(g, v1, v5; boundary=B3)
    add_edge!(g, v3, v5, boundary=B3)
    add_edge!(g, v2, v5, boundary=false)

    add_interior!(g, v1, v2, v5)
    add_interior!(g, v2, v5, v3)

    rem_vertex!(g, center)

    return true
end
