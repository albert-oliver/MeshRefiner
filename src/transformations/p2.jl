function check_P2(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    elseif !get_prop(g, center, :refine)
        return nothing
    end

    vertexes = inneighbors(g, center)

    if !has_edge(g, vertexes[1], vertexes[2]) ||
       !has_edge(g, vertexes[1], vertexes[3]) ||
       !has_edge(g, vertexes[2], vertexes[3])
        return nothing
    end

    for i in 0:2
        v1 = vertexes[i+1]
        v2 = vertexes[(i+1)%3+1]
        v3 = vertexes[(i+2)%3+1]

        B1 = get_prop(g, v1, v2, :boundary)
        B2 = get_prop(g, v2, v3, :boundary)
        B3 = get_prop(g, v1, v3, :boundary)
        L1 = get_prop(g, v1, v2, :length)
        L2 = get_prop(g, v2, v3, :length)
        L3 = get_prop(g, v1, v3, :length)

        if !B1 && L1>=L2 && L1>=L3 && !((B2 && L2==L1) || B3 && L3==L1)
            return v1, v2, v3
        end
    end
    return nothing
end

function transform_P2!(g, center)
    mapping = check_P2(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    p3 = props(g, v3)
    B1 = get_prop(g, v1, v2, :boundary)
    L1 = get_prop(g, v1, v2, :length)

    rem_edge!(g, v1, v2)

    add_vertex!(g)
    v4 = nv(g)
    set_prop!(g, v4, :type, "hanging")
    set_prop!(g, v4, :x, (p1[:x] + p2[:x])/2)
    set_prop!(g, v4, :y, (p1[:y] + p2[:y])/2)
    set_prop!(g, v4, :z, (p1[:z] + p2[:z])/2)
    p4 = props(g, v4)

    add_edge!(g, v4, v1)
    set_prop!(g, v4, v1, :boundary, B1)
    set_prop!(g, v4, v1, :length, L1/2)

    add_edge!(g, v4, v2)
    set_prop!(g, v4, v2, :boundary, B1)
    set_prop!(g, v4, v2, :length, L1/2)

    add_edge!(g, v4, v3)
    set_prop!(g, v4, v3, :boundary, false)
    set_prop!(g, v4, v3, :length, cartesian_distance(p4, p3))

    add_vertex!(g)
    x, y, z = center_point([p1, p3, p4])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v1)
    add_edge!(g, nv(g), v3)
    add_edge!(g, nv(g), v4)

    add_vertex!(g)
    x, y, z = center_point([p2, p3, p4])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), v3)
    add_edge!(g, nv(g), v4)

    rem_vertex!(g, center)
end
