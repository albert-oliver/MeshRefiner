"Module defining hypergraphs type and related functions"
module HyperGraphs
export
    HyperGraph,
    FlatGraph,
    SphereGraph,
    VERTEX, HANGING, INTERIOR,

    # Adding / removing
    add_vertex!,
    add_hanging!,
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
    is_ordinary_edge,
    edges,
    all_edges,

    # Vertex properties
    set_hanging!,
    unset_hanging!,
    get_cartesian,
    xyz,
    coords2D,
    get_type,
    is_hanging,
    is_vertex,
    is_interior,
    get_elevation,
    set_elevation!,
    get_value,
    set_value!,
    get_value_cartesian,
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
    has_edge,

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

const VERTEX = 1
const HANGING = 2
const INTERIOR = 3

"""
Abstract type that holds hypergraph.

In this case hypergraph represents triangle mesh and is a graph with three
types of vertices:
- `VERTEX` - normal vertex of graph
- `HANGING` - hanging node on edge between two normal vertices, made when breaking traingle on one side of edge
- `INTERIOR` - vertex representing inside of trinagle

Vertices are represented by integers starting at 1.

Two concrete subtypes of `HyperGraph` are `FlatGraph` and `SphereGraph`.

# Properties of vertex by its type
- `VERTEX` properties depends on graph subtype
- `HANGING` vertices have same properties as normal vertices, plus:
    - `v1`, `v2`: vertices between which hanging node lies
- `INTERIOR`:
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

Add new vertex to graph `g`. Return its `id`.

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
    add_hanging!(g, v1, v2, elevation; value=0)
    add_hanging!(g, v1, v2, coords, elevation; value=0)

Add hanging node between vertices `v1` and `v2`. Return its `id`. Other arguments
are similar to [`add_vertex!`](@ref).

# Note
Only add new vertex with type `hanging`. **No** other changes will be made
(specifically no edges will be added or removed).

See also: [`add_vertex!`](@ref)
"""
function add_hanging! end

function add_hanging!(
    g::HyperGraph,
    v1::Integer,
    v2::Integer,
    coords::AbstractVector{<:Real};
    value::Real = 0.0,
)
    add_vertex!(g, coords; value = value)
    set_hanging!(g, nv(g), v1, v2)
    nv(g)
end

function add_hanging!(
    g::HyperGraph,
    v1::Integer,
    v2::Integer,
    coords::AbstractVector{<:Real},
    elevation::Real;
    value = 0.0,
)
    add_vertex!(g, coords, elevation; value = value)
    set_hanging!(g, nv(g), v1, v2)
    nv(g)
end

"""
    add_interior!(g, v1, v2, v3; refine=false)
    add_interior!(g, vs; refine=false)

Add interior to graph `g` that represents traingle with vertices `v1`, `v2` and
`v3` (or vector `vs = [v1, v2, v3]`). Return its `id`.

# Note
This will **not** create any edges between those vertices. However it will
create edges between new `INTERIOR` vertex and each of the three.
"""
function add_interior! end

function add_interior!(
    g::HyperGraph,
    v1::Integer,
    v2::Integer,
    v3::Integer;
    refine::Bool = false,
)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, INTERIOR)
    MG.set_prop!(g.graph, nv(g), :refine, refine)
    Gr.add_edge!(g.graph, nv(g), v1)
    Gr.add_edge!(g.graph, nv(g), v2)
    Gr.add_edge!(g.graph, nv(g), v3)
    g.interior_count += 1
    return nv(g)
end

function add_interior!(
    g::HyperGraph,
    vs::AbstractVector{<:Real};
    refine::Bool = false,
)
    add_interior!(vs[v1], vs[v2], vs[v3]; value = value)
end

"Add edge between vertices `v1` and `v2`."
function add_edge!(
    g::HyperGraph,
    v1::Integer,
    v2::Integer;
    boundary::Bool = false,
)
    Gr.add_edge!(g.graph, v1, v2)
    MG.set_prop!(g.graph, v1, v2, :boundary, boundary)
end

"Remove vertex `v` of any type from graph."
function rem_vertex!(g::HyperGraph, v::Integer)
    if is_vertex(g, v)
        g.vertex_count -= 1
    elseif is_hanging(g, v)
        g.hanging_count -= 1
    else
        g.interior_count -= 1
    end
    Gr.rem_vertex!(g.graph, v)
end

"Remove edge from `v1` to `v2` from graph."
rem_edge!(g::HyperGraph, v1::Integer, v2::Integer) =
    Gr.rem_edge!(g.graph, v1, v2)

# -----------------------------------------------------------------------------
# ------ Functions counting elements fo graph  --------------------------------
# -----------------------------------------------------------------------------

"Number of **all** vertices in graph `g`. Alias: [`nv`](@ref)"
all_vertex_count(g::HyperGraph) = Gr.nv(g.graph)

"Number of **all** vertices in graph `g`. Alias of [`vertex_count`](@ref)"
nv = all_vertex_count

"Number of normal vertices in graph `g`"
vertex_count(g::HyperGraph) = g.vertex_count

"Number of hanging nodes in graph `g`"
hanging_count(g::HyperGraph) = g.hanging_count

"Number of interiors in graph `g`"
interior_count(g::HyperGraph) = g.interior_count

# -----------------------------------------------------------------------------
# ------ Iterators over vertices ----------------------------------------------
# -----------------------------------------------------------------------------

"Return vector of all vertices with type `type`"
function vertices_with_type(g::HyperGraph, type::Integer)
    filter_fun(g, v) = MG.get_prop(g, v, :type) == type
    MG.filter_vertices(g.graph, filter_fun)
end

"Return vector of all vertices with type different from `type`"
function vertices_except_type(g::HyperGraph, type::Integer)
    filter_fun(g, v) = MG.get_prop(g, v, :type) != type
    MG.filter_vertices(g.graph, filter_fun)
end

"Return all vertices with type `VERTEX`"
normal_vertices(g::HyperGraph) = vertices_with_type(g, VERTEX)

"Return all vertices with type `HANGING`"
hanging_nodes(g::HyperGraph) = vertices_with_type(g, HANGING)

"Return all vertices with type `INTERIOR`"
interiors(g::HyperGraph) = vertices_with_type(g, INTERIOR)

"Return neighbors with all types of vertex `v`"
neighbors(g::HyperGraph, v::Integer) = Gr.neighbors(g.graph, v)

"Return neighbors with type `type` of vertex `v`"
function neighbors_with_type(g::HyperGraph, v::Integer, type::Integer)
    filter(u -> MG.get_prop(g.graph, u, :type) == type, neighbors(g, v))
end

"Return neighbors with type different than `type` of vertex `v`"
function neighbors_except_type(g::HyperGraph, v::Integer, type::Integer)
    filter(u -> MG.get_prop(g.graph, u, :type) != type, neighbors(g, v))
end

"Return neighbors with type `vertex` of vertex `v`"
vertex_neighbors(g::HyperGraph, v::Integer) = neighbors_with_type(g, v, VERTEX)

"Return neighbors with type `hanging` of vertex `v`"
hanging_neighbors(g::HyperGraph, v::Integer) =
    neighbors_with_type(g, v, HANGING)

"Return neighbors with type `interior` of vertex `v`"
interior_neighbors(g::HyperGraph, v::Integer) =
    neighbors_with_type(g, v, INTERIOR)

"Return three vertices that make triangle represented by interior `i`"
interiors_vertices(g::HyperGraph, i::Integer) = neighbors(g, i)

"Check if edge between `v1` `v2` is ordinary, that is if it doesn't connect
`INTERIOR` to its vertices."
is_ordinary_edge(g::HyperGraph, v1::Integer, v2::Integer) =
    !is_interior(g, v1) && !is_interior(g, v2)

"Return *all* edges in graph `g` (including possibly edges between interiors
and) its vertices. To get ordinary edges use [`edges`](@ref)."
all_edges(g::HyperGraph) = map(e -> [Gr.src(e), Gr.dst(e)], Gr.edges(g.graph))

"Return oridanry edges in graph `g`. To get all edges use [`all_edges`](@ref)."
function edges(g::HyperGraph)
    filter(e -> is_ordinary_edge(g, e[1], e[2]), all_edges(g))
end

# -----------------------------------------------------------------------------
# ------ Functions handling vertex properties  --------------------------------
# -----------------------------------------------------------------------------

"Change type of vertex `v` to `hanging` from `vertex` and set its 'parents' to
`v1` and `v2`"
function set_hanging!(g::HyperGraph, v::Integer, v1::Integer, v2::Integer)
    if !is_hanging(g, v)
        g.hanging_count += 1
        g.vertex_count -= 1
    end
    MG.set_prop!(g.graph, v, :type, HANGING)
    MG.set_prop!(g.graph, v, :v1, v1)
    MG.set_prop!(g.graph, v, :v2, v2)
end

"Change type of vertex to `vertex` from `hanging`"
function unset_hanging!(g::HyperGraph, v::Integer)
    if !is_hanging(g, v)
        return nothing
    end
    MG.set_prop!(g.graph, v, :type, VERTEX)
    MG.rem_prop!(g.graph, v, :v1)
    MG.rem_prop!(g.graph, v, :v2)
    g.hanging_count -= 1
    g.vertex_count += 1
end

# -----------------------------------------------------------------------------
# ------ Used in mosed functions below ----------------------------------------
# -----------------------------------------------------------------------------

"Return vector with cartesian coordinates of vertex `v`. Alias: [`xyz`](@ref)"
get_cartesian(g::HyperGraph, v::Integer) = MG.get_prop(g.graph, v, :xyz)

"Return vector with cartesian coordinates of vertex `v`. Alias of:
[`get_cartesian`](@ref)"
const xyz = get_cartesian

"""
    coords2D(g, v)

Return 2D coordintes of vertex `v`.

For:
- `FlatGraph` return `[x, y]`
- `SphereGraph` return `[lat, lon]`
"""
function coords2D end

get_type(g::HyperGraph, v::Integer)::Integer = MG.get_prop(g.graph, v, :type)
is_hanging(g::HyperGraph, v::Integer) =
    MG.get_prop(g.graph, v, :type) == HANGING
is_vertex(g::HyperGraph, v::Integer) = MG.get_prop(g.graph, v, :type) == VERTEX
is_interior(g::HyperGraph, v::Integer) =
    MG.get_prop(g.graph, v, :type) == INTERIOR
function get_elevation end
function set_elevation! end
get_value(g::HyperGraph, v::Integer)::Real = MG.get_prop(g.graph, v, :value)
set_value!(g::HyperGraph, v::Integer, value::Real) =
    MG.set_prop!(g.graph, v, :value, value)

"Return cartesian coordinates of the point that sits `value` above vertex."
function get_value_cartesian end

"""
    get_all_values(g)

Return vector with values coresponding to `value` property of all vertices
with type `vertex` in graph `g`. Vertices are sorted inascending order based on
their `id`. Mapping between vertex `id` and proper index can be retrieved
using [`vertex_map`](@ref).

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function get_all_values(g::HyperGraph)
    [MG.get_prop(g.graph, v, :value) for v in normal_vertices(g)]
end

"""
    set_all_values!(g, values)

Set `value` property for all vertexes with type `vertex` in graph `g`. Vertex
with smallest `id` will receive value `values[1]`, next one `values[2]` and so
on.

See also: [`set_all_values!`](@ref), [`vertex_map`](@ref)
"""
function set_all_values!(g::HyperGraph, values::AbstractVector{<:Real})
    for (i, v) in enumerate(normal_vertices(g))
        MG.set_prop!(g.graph, v, :value, values[i])
    end
end

should_refine(g::HyperGraph, i::Integer)::Bool =
    MG.get_prop(g.graph, i, :refine)
set_refine!(g::HyperGraph, i::Integer) = MG.set_prop!(g.graph, i, :refine, true)
unset_refine!(g::HyperGraph, i::Integer) =
    MG.set_prop!(g.graph, i, :refine, false)

# -----------------------------------------------------------------------------
# ------ Functions handling edge properties -----------------------------------
# -----------------------------------------------------------------------------

"Is edge between `v1` and `v2` on boundary"
is_on_boundary(g::HyperGraph, v1::Integer, v2::Integer) =
    MG.get_prop(g.graph, v1, v2, :boundary)

set_boundary!(g::HyperGraph, v1::Integer, v2::Integer) =
    MG.set_prop!(g.graph, v1, v2, :boundary, true)
unset_boundary!(g::HyperGraph, v1::Integer, v2::Integer) =
    MG.set_prop!(g.graph, v1, v2, :boundary, true)

"Return length of edge as euclidean distance between cartesian coordiantes of
its vertices"
edge_length(g::HyperGraph, v1::Integer, v2::Integer)::Real =
    norm(xyz(g, v1) - xyz(g, v2))

has_edge(g::HyperGraph, v1::Integer, v2::Integer)::Bool =
    Gr.has_edge(g.graph, v1, v2)

# -----------------------------------------------------------------------------
# ------ Other functions ------------------------------------------------------
# -----------------------------------------------------------------------------

"Whether graph `g` has any hanging nodes"
has_hanging_nodes(g::HyperGraph) = hanging_count(g) != 0

"Get hanging node between normal vertices `v1` and `v2` in graph `g`"
function get_hanging_node_between(g::HyperGraph, v1::Integer, v2::Integer)
    if Gr.has_edge(g.graph, v1, v2)
        return nothing
    end
    hnodes1 = filter(v -> is_hanging(g, v), neighbors(g, v1))
    hnodes2 = filter(v -> is_hanging(g, v), neighbors(g, v2))
    hnodes_all = intersect(hnodes1, hnodes2)

    for h in hnodes_all
        h_is_between = [MG.get_prop(g.graph, h, :v1), MG.get_prop(g.graph, h, :v2)]
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
vertex_map(g::HyperGraph) =
    Dict(v => i for (i, v) in enumerate(normal_vertices(g)))

include("flatgraph.jl")
include("spheregraph.jl")

end # module
