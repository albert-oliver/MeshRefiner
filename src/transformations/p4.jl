function check_P4(g, center)
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

    if !get_prop(g, v1, v3, :boundary)
        if !get_prop(g, v2, v3, :boundary)
            return nothing
        else
            tmp = v1
            v1 = v2
            v2 = tmp
        end
    end

    L1 = get_prop(g, v1, h, :length)
    L2 = get_prop(g, v2, h, :length)
    L3 = get_prop(g, v2, v3, :length)
    L4 = get_prop(g, v1, v3, :length)

    if L4 > (L1+L2) && L4 >= L3
        return v1, v2, v3, h
    end
    return nothing
end

function transform_P4!(g, center)
    mapping = check_P4(g, center)
    if isnothing(mapping)
        return
    end

    v1, v2, v3, h = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    p3 = props(g, v3)

    L4 = get_prop(g, v1, v3, :length)
    B4 = get_prop(g, v1, v3, :boundary)

    add_vertex!(g)
    v5 = nv(g)
    set_prop!(g, v5, :type, "vertex")
    set_prop!(g, v5, :x, (p1[:x] + p3[:x])/2)
    set_prop!(g, v5, :y, (p1[:y] + p3[:y])/2)
    set_prop!(g, v5, :z, (p1[:z] + p3[:z])/2)
    p5 = props(g, v5)

    rem_edge!(g, v1, v3)

    add_edge!(g, v1, v5)
    set_prop!(g, v1, v5, :boundary, B4)
    set_prop!(g, v1, v5, :length, L4/2)

    add_edge!(g, v3, v5)
    set_prop!(g, v3, v5, :boundary, B4)
    set_prop!(g, v3, v5, :length, L4/2)

    add_edge!(g, v2, v5)
    set_prop!(g, v2, v5, :boundary, false)
    set_prop!(g, v2, v5, :length, cartesian_distance(p2, p5))

    add_vertex!(g)
    x, y, z = center_point([p1, p2, p5])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v1)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), v5)

    add_vertex!(g)
    x, y, z = center_point([p2, p5, p3])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), v5)
    add_edge!(g, nv(g), v3)

    rem_vertex!(g, center)
end
