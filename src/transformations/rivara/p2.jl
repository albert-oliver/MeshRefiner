function check_p2(g::HyperGraph, center::Integer)
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

"""
    transform_p2!(g, center)

Run transgormation P2 on triangle represented by interior `center`.

One edge with hanging node that is the longest edge.

```text
     v                v
    / \\              /|\\
   /   \\     =>     / | \\
  /     \\          /  |  \\
 v---h---v        v---h---v
```

Conditions:
- Breaks triangle if hanging node is on the longes edge
"""
function transform_p2!(g::HyperGraph, center::Integer)
    mapping = check_p2(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3, h = mapping

    unset_hanging!(g, h)

    add_edge!(g, h, v3)

    add_interior!(g, v1, v3, h)
    add_interior!(g, v2, v3, h)

    rem_vertex!(g, center)

    return true
end
