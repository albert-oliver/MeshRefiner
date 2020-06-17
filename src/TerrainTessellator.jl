using LightGraphs
using MetaGraphs
using Statistics

include("utils.jl")
include("transformations/p1.jl")
include("transformations/p2.jl")
include("transformations/p3.jl")
include("transformations/p4.jl")
include("transformations/p5.jl")
include("transformations/p6.jl")
include("transformations/p7.jl")
include("transformations/p8.jl")
include("transformations/p9.jl")
include("graphs/example_graphs.jl")
include("graphs/test_graphs.jl")

function run_for_all_triangles!(g, fun)
    executed_sth = false
    for v in nv(g):-1:1
        if get_prop(g, v, :type) == "interior"
            # executed_sth |= fun(g, v)
            ex = fun(g, v)
            if ex
                println("Executing: ", String(Symbol(fun)))
            end
            executed_sth |= ex
        end
    end
    return executed_sth
end

function run_transformations!(g)
    run_for_all_triangles!(g, transform_P1!)
    run_for_all_triangles!(g, transform_P2!)
    while true
        executed_sth = false
        executed_sth |= run_for_all_triangles!(g, transform_P3!)
        executed_sth |= run_for_all_triangles!(g, transform_P4!)
        executed_sth |= run_for_all_triangles!(g, transform_P5!)
        executed_sth |= run_for_all_triangles!(g, transform_P6!)
        executed_sth |= run_for_all_triangles!(g, transform_P7!)
        executed_sth |= run_for_all_triangles!(g, transform_P8!)
        executed_sth |= run_for_all_triangles!(g, transform_P9!)
        if !executed_sth
            return
        end
    end
end

g = example_graph_2()
run_transformations!(g)
draw_graph(g)
# draw_makie(g)
