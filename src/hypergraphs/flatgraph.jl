import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
import Base: show

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

function show(io::IO, g::FlatGraph)
    vs = g.vertex_count
    ins = g.interior_count
    hs = g.hanging_count
    es = length(edges(g))
    print(
        io,
        "FlatGraph with ($(vs) vertices), ($(ins) interiors), ($(hs) hanging nodes) and ($(es) edges)",
    )
end

# -----------------------------------------------------------------------------
# ------ Methods for HyperGraph functions -------------------------------------
# -----------------------------------------------------------------------------

function project!(g::FlatGraph, v::Integer, elevation::Real)
    param_coords = uv(g, v)
    coords = vcat(param_coords, elevation)
    MG.set_prop!(g.graph, v, :xyz, coords)
end

"""
distance(g, v1, v2)

Returns the distance between two vertices of the hypergraph.

#Note:
 - This method is used to compute the longest edge

"""
distance(g::FlatGraph, v1, v2) = norm(uv(g, v2) - uv(g, v1))

