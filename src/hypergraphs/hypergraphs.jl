"Module defining hypergraphs type and related functions"
module HyperGraphs

import MetaGraphs; const MG = MetaGraphs
import Graphs; const Gr = Graphs

"""
Abstract type that holds hypergraph.

In this case hypergraph represents triangle mesh and is a graph with three
types of vertices:
- `vertex` - normal vertex of graph
- `hanging` - hanging node on edge between two normal vertices, made when breaking traingle on one side of edge
- `interior` - vertex representing inside of trinagle

Vertices are represented by integers starting at 1.

Two concrete subtypes of `HyperGraph` are `FlatGraph` and `SphereGraph`.

# Vertex properties
- `vertex` properteis depends on subtype
- `hanging` vertices have same properties as normal vertices plus:
    - `v1`, `v2`: vertices between which hanging node lies
- Interiors (type `interior`):
    - `refine::Bool`: whether this traingle should be refined
# Edge properties
- `boundary::Bool` - whether this edge lies on boundary of mesh

See also: [`FlatGraph`](@ref), [`SphereGraph`](@ref)
"""
abstract type HyperGraph end

"""
    add_vertex!(g, coords; value=0)
    add_vertex!(g, coords, elevation; value=0)

Add new vertex to graph `g`.

## For `FlatGraph`:
- when `elevation` is not delivered add vertex with coordinates:
    - `x = coords[1]`
    - `y = coords[2]`
    - `elevation = z = coords[3]`
- when `elevation` is delivered only two first elements of `coords` are used
## For `SphereGraph`
- when `elevation` is not delivered add vertex with coordinates:
    - `x = coords[1]`
    - `y = coords[2]`
    - `z = coords[3]`
    - and calculate `lat`, `lon` and `elevation`
- when `elevation` is delivered:
    - `lat = coords[1]`
    - `lon = coords[2]`
    - `elevation = elevation`
    - and calculate `x`, `y`, `z`
"""
function add_vertex! end

"""
    add_hanging!(g, v1, v2)

Add hanging node between vertices `v1` and `v2`

# Note
This will remove edge between those vertices and calculate new vertex
coordinates based on `v1` and `v2`.
"""
function add_hanging! end

"""
    add_interior!(g, v1, v2, v3)

Add interior to graph `g` that represents traingle with vertices `v1`, `v2` and
`v3`.

# Note
This will **not** create any edges betwwen those vertices.
"""
function add_interior! end

"Number of vertices in graph `g`. Alias: [`nv`](@ref)"
function vertex_count end

"Number of vertices in graph `g`. Alias of [`vertex_count`](@ref)"
function nv end

"Number of interiors in graph `g`"
function interior_count end

"Return vector of all vertices with type `type`"
function vertices_with_type end

"Return vector of all vertices with type different from `type`"
function vertices_except_type end

"Return all vertices with type `vertex`"
function normal_vertices end

"Return all vertices with type `hanging`"
function hanging_nodes end

"Return all vertices with type `interior`"
function interiors end

"Whether graph `g` has any janging nodes"
function has_hanging_nodes end

"Get hanging node between normal vertices `v1` and `v2` in graph `g`"
function get_hanging_node_between end

function is_hanging end
function is_vertex end
function is_interior end
function is_on_boundary end
function set_boundary! end
function get_elevation end
function set_elevation! end
function set_value! end
function get_value end
function should_refine end
function set_refine! end

"""
    get_all_values(g)

Return vector with values coresponding to `value` property of all vertices
with type `vertex` in graph `g`. Vertices are sorted inascending order based on
their `id`. Mapping between vertex `id` and proper index can be retrieved
using [`vertex_map`](@ref).

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function get_all_values end

"""
    set_all_values!(g, values)

Set `value` property for all vertexes with type `vertex` in graph `g`. Vertex
with smallest `id` will receive value `values[1]`, next one `values[2]` and so
on.

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function set_all_values! end

"Return length of edge as euclidean distance between cartesian coordiantes of
its vertices"
function edge_length end

"Return dictionary that maps id's of all vertices with type `vertex` to number
starting at 1."
function vertex_map end

"Return vector with xyz coordinates of vertex."
function xyz end

include("flatgraph.jl")
include("spheregraph.jl")

end # module
