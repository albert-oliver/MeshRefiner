using LightGraphs
using MetaGraphs
using Statistics

include("utils.jl")
include("transformations/p1.jl")
include("graphs/p1_graph.jl")
include("transformations/p2.jl")
include("graphs/p2_graph.jl")
include("transformations/p3.jl")
include("graphs/p3_graph.jl")

g = P3_graph()
transform_P3!(g, 1)
draw_graph(g)
