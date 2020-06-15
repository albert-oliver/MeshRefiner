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
include("transformations/p4.jl")
include("graphs/p4_graph.jl")
include("transformations/p5.jl")
include("graphs/p5_graph.jl")

g = P5_graph()
transform_P5!(g, 1)
draw_graph(g)
