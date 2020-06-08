function check_P1(g, center)
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

    h = nothing
    v1 = nothing
    v2 = nothing
    if get_prop(g, vertexes[1], :type) == "hanging"
        h = vertexes[1]
        v1 = vertexes[2]
        v2 = vertexes[3]
    elseif get_prop(g, vertexes[2], :type) == "hanging"
        h = vertexes[2]
        v1 = vertexes[1]
        v2 = vertexes[3]
    elseif get_prop(g, vertexes[3], :type) == "hanging"
        h = vertexes[3]
        v1 = vertexes[1]
        v2 = vertexes[2]
    else
        return nothing
    end

    B1 = get_prop(g, v1, v2, :boundary)
    L1 = get_prop(g, v1, v2, :length)
    L2 = get_prop(g, h, v1, :length)
    L3 = get_prop(g, h, v2, :length)

    if B1 && (L1 >= L2) && (L1 >= L3)
        return h, v1, v2
    end
end

function transform_P1!(g, center)
    mapping = check_P1(g, center)
    if isnothing(mapping)
        return
    end

    h, v1, v2 = mapping
    p1 = props(g, v1)
    p2 = props(g, v2)
    ph = props(g, h)
    B1 = get_prop(g, v1, v2, :boundary)
    L1 = get_prop(g, v1, v2, :length)

    rem_edge!(g, v1, v2)

    add_vertex!(g)
    v4 = nv(g)
    set_prop!(g, v4, :type, "vertex")
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

    add_edge!(g, v4, h)
    set_prop!(g, v4, h, :boundary, false)
    set_prop!(g, v4, h, :length, cartesian_distance(p4, ph))

    add_vertex!(g)
    x, y, z = center_point([p1, ph, p4])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v1)
    add_edge!(g, nv(g), h)
    add_edge!(g, nv(g), v4)

    add_vertex!(g)
    x, y, z = center_point([p2, ph, p4])
    set_prop!(g, nv(g), :type, "interior")
    set_prop!(g, nv(g), :refine, false)
    set_prop!(g, nv(g), :x, x)
    set_prop!(g, nv(g), :y, y)
    set_prop!(g, nv(g), :z, z)
    add_edge!(g, nv(g), v2)
    add_edge!(g, nv(g), h)
    add_edge!(g, nv(g), v4)

    rem_vertex!(g, center)

end
