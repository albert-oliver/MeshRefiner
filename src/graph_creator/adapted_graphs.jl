using ..Adaptation

function regular_flat_mesh(; subdivisions::Integer=10, dims=(1.0, 1.0))
    g = simple_graph(dims)

    for i in 1:subdivisions
        for interior in interiors(g)
            set_refine!(g, interior)
        end
        Adaptation.refine!(g)
    end

    zero_fun(p) = 0.0
    match_to_fun!(g, zero_fun)

    g
end

function regular_pool_mesh(; subdivisions::Integer=10, dims=1.0, depth::Real=0.5)
    g = regular_flat_mesh(subdivisions=subdivisions, dims=dims)
    for v in normal_vertices(g)
        set_elevation!(g, v, -depth)
        set_value!(g, v, depth)
    end
    g
end

function regular_slope_mesh(; subdivisions::Integer=10, dims=(1.0, 1.0), height=1.0)
    g = regular_flat_mesh(subdivisions, dims)

    for v in normal_vertices(g)
        z_val = -(height / dims[1]) * x(g, v) + height
        set_elevation!(g, v, z_val)
    end

    g
end

function regular_channel_mesh(; subdivisions=10, dims=(1.0, 1.0), height=1.0)
    g = regular_flat_mesh(subdivisions=subdivisions, dims=dims)

    yp = dims[2] / 2.0
    for v in normal_vertices(g)
        z_val  = (-(height / dims[1]) * x(g, v) + height) / 2.0
        z_val += height / 2.0 * abs(y(g, v) - yp) / (dims[2] / 2.0)
        set_elevation!(g, v, z_val)
    end

    g
end

function mesh_hat_fun(dims = (1.0, 1.0), height = 1.0)
    center = (0.5, 0.5)

    function hat_fun(x, y)
        xp = center[1]
        yp = center[2]
        r=((x/dims[1]-xp)^2+(y/dims[2]-yp)^2)^0.5
        f(r) = r < 1 ? cos(2*π*r) * height : 0.0
        f(r)
    end

    g = regular_flat_mesh(10, dims=dims)
    match_to_fun!(g, hat_fun)
    g
end
