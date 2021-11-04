import Graphsl; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
using LinearAlgebra

"""
`HyperGraph` whose vertices are on flat surface but can be moved up and down
with `elevation` property.

Can represent samll part Earth's surface, where curvature is negligible.

# Verticex properties
All properties are the same as in `HyperGraph` except for the following:
- `vertex` type vertices:
    - `xyz` - cartesian coordinates of vertex (include elvation as `xyz[3]`)
    - `value` - custom property of vertex - for instance water

See also: [`HyperGraph`](@ref)
"""
mutable struct FlatGraph <: HyperGraph
    graph::MetaGraph
    vertices_count::Integer
    interior_count::Integer
    hanging_count::Integer
end

function FlatGraph()
    graph = MG.MetaGraph()
    FlatGraph(graph, 0, 0, 0)
end

function add_vertex!(g::FlatGraph, coords::Vector{Real}; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, "vertex")
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g.graph, nv(g), :xyz, coords[1:3])
    g.vertices_count += 1
    return nv(g)
end

function add_vertex!(g::FlatGraph, coords::Vector{Real}, elevation::Real; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, "vertex")
    MG.set_prop!(g.graph, nv(g), :value, value)
    xyz = vcat(coords[1:2], [elevation])
    MG.set_prop!(g.graph, nv(g), :xyz, xyz)
    g.vertices_count += 1
    return nv(g)
end

function add_hanging!(g::FlatGraph, v1, v2)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g, nv(g), :type, "hanging")
    MG.set_prop!(g.graph, nv(g), :value, 0.0)
    xyz = (xyz(g, v1) + xyz(g, v2)) / 2.0
    MG.set_prop!(g.graph, nv(g), :xyz, xyz)
    MG.set_prop!(g.graph, nv(g), :v1, v1)
    MG.set_prop!(g.graph, nv(g), :v2, v2)
    g.hanging_count += 1
    return nv(g)
end

function get_elevation(g::FlatGraph, v) MG.get_prop(g, v, :xyz)[3]

function set_elevation!(g, v, elevation)
    xyz = MG.get_prop(g, v, :xyz)
    xyz[3] = elevation
    MG.set_prop!(g, v, :xyz, xyz)
end
