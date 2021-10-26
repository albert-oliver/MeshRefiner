using ..Utils

using MetaGraphs
using Graphs

function check_p5(g, center)
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

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h1 = nothing
    h2 = nothing

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
    HN1 = get_prop(g, v1, :type) == "hanging" ? true : false
    HN3 = get_prop(g, v3, :type) == "hanging" ? true : false

    if L5 > (L1+L2) && L5 > (L3+L4) && (!HN1 && !HN3)
        return v1, v2, v3
    end
    return nothing
end

"""
    transform_p5!(g, center)

Run transgormation P5 on triangle represented by interior `center`.

Two edges with hanging node, none of them is the longest edge.

```text
     v                v
    / \\              /|\\
   h   h     =>     h | h
  /     \\          /  |  \\
 v-------v        v---h---v
```

Conditions:
- Breaks *longest edge* (note that it is the one without hanging node)
- It's vertices are not hanging nodes
"""
function transform_p5!(g, center)
    mapping = check_p5(g, center)
    if isnothing(mapping)
        return false
    end

    v1, v2, v3 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    p3 = props(g, v3)

    B5 = get_prop(g, v1, v3, :boundary)

    v6 = add_meta_vertex!(g, (p1[:x] + p3[:x])/2, (p1[:y] + p3[:y])/2, (p1[:z] + p3[:z])/2)
    if !B5
        set_prop!(g, v6, :type, "hanging")
    end

    add_meta_edge!(g, v1, v6, B5)
    add_meta_edge!(g, v6, v3, B5)
    add_meta_edge!(g, v2, v6, false)

    add_interior!(g, v1, v2, v6, false)
    add_interior!(g, v6, v2, v3, false)

    rem_edge!(g, v1, v3)
    rem_vertex!(g, center)

    return true
end
