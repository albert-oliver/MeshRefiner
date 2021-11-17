import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
using LinearAlgebra

# -----------------------------------------------------------------------------
# ------ FlatGraph type definition and constructors ---------------------------
# -----------------------------------------------------------------------------

"""
`FlatGraph` is a `HyperGraph` whose vertices are on flat surface but can be
moved up and down with `elevation` property.

Can represent samll part Earth's surface, where curvature is negligible.

# Verticex properties
All properties are the same as in `HyperGraph` except for the following:
- `VERTEX` type vertices:
    - `xyz` - cartesian coordinates of vertex (include elvation as `xyz[3]`)
    - `value` - custom property of vertex - for instance water

See also: [`HyperGraph`](@ref)
"""
mutable struct FlatGraph <: HyperGraph
    graph::MG.MetaGraph
    vertex_count::Integer
    interior_count::Integer
    hanging_count::Integer
end

function FlatGraph()
    graph = MG.MetaGraph()
    FlatGraph(graph, 0, 0, 0)
end

# -----------------------------------------------------------------------------
# ------ Methods for HyperGraph functions -------------------------------------
# -----------------------------------------------------------------------------

function add_vertex!(g::FlatGraph, coords; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, VERTEX)
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g.graph, nv(g), :xyz, coords[1:3])
    g.vertex_count += 1
    return nv(g)
end

function add_vertex!(g::FlatGraph, coords, elevation::Real; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, VERTEX)
    MG.set_prop!(g.graph, nv(g), :value, value)
    xyz = vcat(coords[1:2], [elevation])
    MG.set_prop!(g.graph, nv(g), :xyz, xyz)
    g.vertex_count += 1
    return nv(g)
end

get_elevation(g::FlatGraph, v) = MG.get_prop(g.graph, v, :xyz)[3]

function set_elevation!(g::FlatGraph, v, elevation)
    coords = MG.get_prop(g.graph, v, :xyz)
    coords[3] = elevation
    MG.set_prop!(g, v, :xyz, coords)
end

get_value_cartesian(g::FlatGraph, v) = xyz(g, v) + [0, 0, get_value(g, v)]
