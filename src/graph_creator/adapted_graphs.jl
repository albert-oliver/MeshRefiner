using ..Adaptation
using ..Utils

function regular_flat_mesh(subdivisions::Integer; dims=(1.0, 1.0))
    g = simple_graph(dims)

    for i in 1:subdivisions
        for interior in interiors(g)
            set_prop!(g, interior, :refine, true)
        end
        Adaptation.run_transformations!(g)
    end

    g
end

function mesh_hat_fun(dims = (1.0, 1.0), height = 1.0)
    center = (0.5, 0.5)

    function hat_fun(x, y)
        xp = center[1]
        yp = center[2]
        r=((x/dims[1]-xp)^2+(y/dims[2]-yp)^2)^0.5
        f(r) = r < 0.25 ? cos(2*π*r) * height : 0.0
        f(r)
    end

    g = regular_flat_mesh(10, dims=dims)
    match_to_fun!(g, hat_fun)
    g
end
