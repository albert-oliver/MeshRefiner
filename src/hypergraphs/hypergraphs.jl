"Module defining hypergraphs type and related functions"
module HyperGraphs
export
    HyperGraph,
    FlatGraph,
    SphereGraph,

    # Adding / removing
    add_vertex!,
    add_hangign!,
    add_interior!,
    add_edge!,
    rem_vertex!,
    rem_edge!,

    # Counts
    all_vertex_count,
    nv,
    vertex_count,
    hanging_count,
    interior_count,

    # Iteratable
    vertices_with_type,
    vertices_except_type,
    normal_vertices,
    hanging_nodes,
    interiors,
    neighbors,
    neighbors_with_type,
    neighbors_except_type,
    vertex_neighbors,
    hanging_neighbors,
    interior_neighbors,
    interiors_vertices,

    # Vertex properties
    unset_hanging!,
    get_cartesian,
    xyz,
    is_hanging,
    is_vertex,
    is_interior,
    get_elevation,
    set_elevation!,
    get_value,
    set_value!,
    get_all_values,
    set_all_values!,
    should_refine,
    set_refine!,
    unset_refine!,

    # Edge properties
    is_on_boundary,
    set_boundary!,
    unset_boundary!,
    edge_length,

    # Other
    has_hanging_nodes,
    get_hanging_node_between,
    vertex_map,

    # SphereGraph only
    gcs,
    get_spherical,
    lat,
    lon

import MetaGraphs; const MG = MetaGraphs
import Graphs; const Gr = Graphs

# -----------------------------------------------------------------------------
# ------ HyperGraph type definition -------------------------------------------
# -----------------------------------------------------------------------------

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


# -----------------------------------------------------------------------------
# ------ Functions for adding and removing vertices and edges -----------------
# -----------------------------------------------------------------------------

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
    - `lat = coords[1]` has to be in range [-90, 90]
    - `lon = coords[2]` can be any real number, is moved to range (-180, 180]
    - `elevation = elevation`
    - and calculate `x`, `y`, `z`
"""
function add_vertex! end

"""
    add_hanging!(g, v1, v2)

Add hanging node between vertices `v1` and `v2`.

# Note
This will remove edge between those vertices and calculate new vertex
coordinates based on `v1` and `v2`.
"""
function add_hanging! end

"""
    add_interior!(g, v1, v2, v3; refine=false)
    add_interior!(g, vs; refine=false)

Add interior to graph `g` that represents traingle with vertices `v1`, `v2` and
`v3` (or vector `vs = [v1, v2, v3]`)

# Note
This will **not** create any edges betwwen those vertices.
"""
function add_interior! end

function add_interior!(g, v1, v2, v3; refine=false)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, "interior")
    MG.set_prop!(g.graph, nv(g), :refine, refine)
    Gr.add_edge!(g.graph, nv(g), v1)
    Gr.add_edge!(g.graph, nv(g), v2)
    Gr.add_edge!(g.graph, nv(g), v3)
    g.interior_count += 1
    return nv(g)
end

function add_interior!(g, vs; refine=false)
    add_interior!(vs[v1], vs[v2], vs[v3]; value=value)
end

"Add edge between vertices `v1` and `v2`."
function add_edge!(g, v1, v2,; boundary=false)
    Gr.add_edge!(g.graph, v1, v2)
    MG.set_prop!(g.graph, v1, v2, :boundary, boundary)
end

"Remove vertex `v` of any type from graph."
function rem_vertex!(g, v)
    if is_vertex(g, v)
        g.vertex_count -= 1
    elseif is_hanging(g, v)
        g.hanging_count -= 1
    else
        g.interior_count -=1
    end
    Gr.rem_vertex!(g, v)
end

"Remove edge from `v1` to `v2` from graph."
rem_edge!(g, v1, v2) = Gr.rem_vertex!(g, v1, v2)

# -----------------------------------------------------------------------------
# ------ Functions counting elements fo graph  --------------------------------
# -----------------------------------------------------------------------------

"Number of **all** vertices in graph `g`. Alias: [`nv`](@ref)"
all_vertex_count(g) = Gr.nv(g.graph)

"Number of **all** vertices in graph `g`. Alias of [`vertex_count`](@ref)"
nv = all_vertex_count

"Number of normal vertices in graph `g`"
vertex_count(g) = g.vertex_count

"Number of hanging nodes in graph `g`"
hanging_count(g) = g.hanging_count

"Number of interiors in graph `g`"
interior_count(g) = g.interior_count

# -----------------------------------------------------------------------------
# ------ Iterators over vertices ----------------------------------------------
# -----------------------------------------------------------------------------

"Return vector of all vertices with type `type`"
function vertices_with_type(g, type::String)
    filter_fun(g, v) = if get_prop(g.graph, v, :type) == type true else false end
    Gr.filter_vertices(g, filter_fun)
end

"Return vector of all vertices with type different from `type`"
function vertices_except_type(g, type::String)
    filter_fun(g, v) = if get_prop(g.graph, v, :type) != type true else false end
    Gr.filter_vertices(g, filter_fun)
end

"Return all vertices with type `vertex`"
normal_vertices(g) = vertices_with_type(g, "vertex")

"Return all vertices with type `hanging`"
hanging_nodes(g) = vertices_with_type(g, "hanging")

"Return all vertices with type `interior`"
interiors(g) = vertices_with_type(g, "interior")

"Return neighbors with all types of vertex `v`"
neighbors(g, v) = Gr.neighbors(g.graph, v)

"Return neighbors with type `type` of vertex `v`"
function neighbors_with_type(g, v, type)
    filter(u -> MG.get_prop(g.graph, u, :type) == type, neighbors(g, v))
end

"Return neighbors with type different than `type` of vertex `v`"
function neighbors_except_type(g, v, type)
    filter(u -> MG.get_prop(g.graph, u, :type) != type, neighbors(g, v))
end

"Return neighbors with type `vertex` of vertex `v`"
vertex_neighbors(g, v) = neighbors_with_type(g, v, "vertex")

"Return neighbors with type `hanging` of vertex `v`"
hanging_neighbors(g, v) = neighbors_with_type(g, v, "hanging")

"Return neighbors with type `interior` of vertex `v`"
interior_neighbors(g, v) = neighbors_with_type(g, v, "interior")

"Return three vertices that make triangle represented by interior `i`"
interiors_vertices(g, i) = neighbors(g, i)

# -----------------------------------------------------------------------------
# ------ Functions handling vertex properties  --------------------------------
# -----------------------------------------------------------------------------

"Changes type of vertex to `vertex` from `hanging`"
function unset_hanging!(g, v)
    MG.set_prop!(g.graph, v, :type, "vertex")
    MG.rem_prop!(g.graph, v, :v1)
    MG.rem_prop!(g.graph, v, :v2)
    g.hanging_count -= 1
    g.vertex_count += 1
end

"Return vector with cartesian coordinates of vertex `v`. Alias: [`xyz`](@ref)"
get_cartesian(g::HyperGraph, v) = MG.get_prop(g.graph, v, :xyz)

"Return vector with cartesian coordinates of vertex `v`. Alias of:
[`get_cartesian`](@ref)"
xyz = get_cartesian

is_hanging(g, v) = MG.get_prop(g.graph, v, :type) == "hanging"
is_vertex(g, v) = MG.get_prop(g.graph, v, :type) == "vertex"
is_interior(g, v) = MG.get_prop(g.graph, v, :type) == "interior"
function get_elevation end
function set_elevation! end
get_value(g, v) = MG.get_prop(g.graph, v, :value)
set_value!(g, v, value) = MG.set_prop!(g.graph, v, :value, value)

"""
    get_all_values(g)

Return vector with values coresponding to `value` property of all vertices
with type `vertex` in graph `g`. Vertices are sorted inascending order based on
their `id`. Mapping between vertex `id` and proper index can be retrieved
using [`vertex_map`](@ref).

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function get_all_values(g)
    [MG.get_prop(g.graph, v, :value) for v in normal_vertices(g)]
end

"""
    set_all_values!(g, values)

Set `value` property for all vertexes with type `vertex` in graph `g`. Vertex
with smallest `id` will receive value `values[1]`, next one `values[2]` and so
on.

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function set_all_values!(g, values)
    for (i, v) in enumerate(normal_vertices(g))
        set_prop!(g.graph, v, :value, values[i])
    end
end

should_refine(g, i) = MG.get_prop!(g.graph, i, :refine)
set_refine!(g, i) = MG.set_prop!(g.graph, i, :refine, true)
unset_refine!(g, i) = MG.set_prop!(g.graph, i, :refine, false)

# -----------------------------------------------------------------------------
# ------ Functions handling edge properties -----------------------------------
# -----------------------------------------------------------------------------

"Is edge between `v1` and `v2` on boundary"
is_on_boundary(g, v1, v2) = MG.get_prop(g.graph, v1, v2, :boundary)

set_boundary!(g, v1, v2) = MG.set_prop!(g.graph, v1,v2, :boundary, true)
unset_boundary!(g, v1, v2) = MG.set_prop!(g.graph, v1,v2, :boundary, true)

"Return length of edge as euclidean distance between cartesian coordiantes of
its vertices"
edge_length(g, v1, v2) = norm(xyz(g, v1) - xyz(g, v2))

# -----------------------------------------------------------------------------
# ------ Ther functions -------------------------------------------------------
# -----------------------------------------------------------------------------

"Whether graph `g` has any hanging nodes"
has_hanging_nodes(g) = hanging_count(g) != 0

"Get hanging node between normal vertices `v1` and `v2` in graph `g`"
function get_hanging_node_between(g, v1, v2)
    if Gr.has_edge(g.graph, v1, v2)
        return nothing
    end
    hnodes1 = filter(v -> is_hanging(v), neighbors(g, v1))
    hnodes2 = filter(v -> is_hanging(v), neighbors(g, v2))
    hnodes_all = intersect(hnodes1, hnodes2)

    for h in hnodes_all
        h_is_between = [MG.get_prop(g.graph, h, :v1), MG.get_prop(g.graph, h, :v1)]
        if v1 in h_is_between && v2 in h_is_between
            return h
        end
    end

    return nothing
end

"""
    vertex_map(g)

Return dictionary that maps id's of all vertices with type `vertex` to number
starting at 1.

# Note
Removing vertices from graph **will** make previously generated mapping
deprecated.
"""
vertex_map(g) =  Dict(v => i for (i, v) in enumerate(normal_vertices(g)))

include("flatgraph.jl")
include("spheregraph.jl")

end # module
