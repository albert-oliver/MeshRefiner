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

g = P9_graph()
transform_P9!(g, nv(g))
draw_graph(g)
