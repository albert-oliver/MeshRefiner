using LightGraphs
using MetaGraphs
using Statistics

include("utils.jl")
include("transformations/p1.jl")

g = MetaGraph()
add_vertex!(g)
add_vertex!(g)
add_vertex!(g)
add_vertex!(g)

set_prop!(g, 1, :type, "interior")
set_prop!(g, 2, :type, "vertex")
set_prop!(g, 3, :type, "hanging")
set_prop!(g, 4, :type, "vertex")

set_prop!(g, 1, :refine, true)

set_prop!(g, 2, :x, 0.0)
set_prop!(g, 2, :y, 0.0)
set_prop!(g, 3, :x, 1.0)
set_prop!(g, 3, :y, 0.0)
set_prop!(g, 4, :x, 0.5)
set_prop!(g, 4, :y, 1.0)
set_prop!(g, 2, :z, 0.0)
set_prop!(g, 3, :z, 1.0)
set_prop!(g, 4, :z, -1.0)
x1, y1, z1 = center_point([props(g, 2), props(g, 3), props(g, 4)])
set_prop!(g, 1, :x, x1)
set_prop!(g, 1, :y, y1)
set_prop!(g, 1, :z, z1)

add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 4)
add_edge!(g, 2, 3)
add_edge!(g, 3, 4)
add_edge!(g, 4, 2)

set_prop!(g, 2, 3, :boundary, false)
set_prop!(g, 2, 3, :length, distance(g, 2, 3))
set_prop!(g, 3, 4, :boundary, false)
set_prop!(g, 3, 4, :length, distance(g, 3, 4))
set_prop!(g, 4, 2, :boundary, true)
set_prop!(g, 4, 2, :length, distance(g, 4, 2))

draw_graph(g)

transform_P1!(g, 1)
draw_graph(g)
