function check_p4(g::HyperGraph, center::Integer)

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

"""
    transform_p4!(g, center)

Run transgormation P4 on triangle represented by interior `center`.

Two edges with hanging node, one of them is the longest edge.

```text
     v                v
    / \\              /|\\
   h   \\     =>     h | \\
  /     \\          /  |  \\
 v---h---v        v---h---v
```

Conditions:
- Breaks triangle if hanging node is on the longes edge
"""
function transform_p4!(g::HyperGraph, center::Integer)
    mapping = check_p4(g, center)
    if isnothing(mapping)
        return false, nothing
    end

    v1, v2, v3, h1, h2 = mapping

    add_edge!(g, v3, h1)
    unset_hanging!(g, h1)

    add_interior!(g, v1, h1, v3)
    add_interior!(g, h1, v2, v3)

    rem_vertex!(g, center)

    return true, nothing
end
