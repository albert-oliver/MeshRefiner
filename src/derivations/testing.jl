

function ortho_order(g, i)
    v1 = get_prop(g, i, :v1)
    v2 = get_prop(g, i, :v2)
    v3 = get_prop(g, i, :v3)
    v1coor = get_coor(g, v1)
    v2coor = get_coor(g, v2)
    v3coor = get_coor(g, v3)
    if dot(v2coor - v1coor, v3coor - v1coor) == 0
        return v1, v2, v3
    end
    if dot(v3coor - v2coor, v1coor - v2coor) == 0
        return v2, v1, v3
    end
    if dot(v1coor - v3coor, v2coor - v3coor) == 0
        return v3, v1, v2
    end
    return nothing
end

function get_matrix_inverse(v1, v2, v3)
    vx = v2 - v1
    vy = v3 - v1
    translate = v1
    scalex = norm(vx)
    scaley = norm(vy)
    vx = normalize(vx)
    vy = normalize(vy)

    S = [
        1.0/scalex 0.0 0.0;
        0.0 1.0/scaley 0.0;
        0.0 0.0 1.0;
    ]
    R = hcat(vcat(vx, 0), vcat(vy, 0), [0,0,1])
    R = transpose(R)
    T = hcat([1,0,0], [0,1,0], vcat(-translate, 1))
    return S*R*T
end

function get_matrix_transpose(v1, v2, v3)
    vx = v2 - v1
    vy = v3 - v1
    translate = v1
    scalex = norm(vx)
    scaley = norm(vy)
    vx = normalize(vx)
    vy = normalize(vy)

    S = [
        1.0/scalex 0.0 0.0;
        0.0 1.0/scaley 0.0;
        0.0 0.0 1.0;
    ]
    R = hcat(vcat(vx, 0), vcat(vy, 0), [0,0,1])
    R = transpose(R)
    T = hcat([1,0,0], [0,1,0], vcat(-translate, 1))
    return S*R*T
end
