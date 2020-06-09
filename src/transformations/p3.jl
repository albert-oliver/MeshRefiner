function check_P3(g, center)
    if get_prop(g, center, :type) != "interior"
        return nothing
    end

    vertexes = inneighbors(g, center)

    v1 = nothing
    v2 = nothing
    v3 = nothing
    h = nothing
    for i in 0:2
        v1 = vertexes[i+1]
        v2 = vertexes[(i+1)%3+1]
        v3 = vertexes[(i+2)%3+1]
        h = get_hanging_node_between(g, v1, v2)
        if !isnothing(h)
            break
        end
    end
    if isnothing(h)
        return nothing
    end

    if !has_edge(g, v1, v3) ||
       !has_edge(g, v2, v3)
        return nothing
    end

    L1 = get_prop(g, v1, h, :length)
    L2 = get_prop(g, v2, h, :length)
    L3 = get_prop(g, v2, v3, :length)
    L4 = get_prop(g, v1, v3, :length)

    if (L1+L2) >= L3 && (L1+L2) >= L4
        return v1, v2, v3, h
    end
    return nothing
end

function transform_P3!(g, center)
    mapping = check_P3(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3, h = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    p3 = props(g, v3)
    ph = props(g, h)

    set_prop!(g, h, :type, "vertex")

    add_edge!(g, h, v3)
    set_prop!(g, h, v3, :boundary, false)
    set_prop!(g, h, v3, :length, cartesian_distance(ph, p3))

    add_vertex!(g)
    x, y, z = center_point([p1, p3, ph])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v1)
    add_edge!(g, nv(g), v3)
    add_edge!(g, nv(g), h)

    add_vertex!(g)
    x, y, z = center_point([p2, p3, ph])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), v3)
    add_edge!(g, nv(g), h)

    rem_vertex!(g, center)
end
