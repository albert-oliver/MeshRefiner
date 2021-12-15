import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
import Base: show
using LinearAlgebra

# -----------------------------------------------------------------------------
# ------ SphereGraph type definition and constructors -------------------------
# -----------------------------------------------------------------------------

"""
`SphereGraph` is a `HyperGraph` whose vertices are on sphere with radius
`radius`.

Can represent Earth's surface where elevation above (or below) sea level is
set using `elevation` property.

# Verticex properties
All properties are the same as in `HyperGraph` except for the following:
- `VERTEX` type vertices:
    - `xyz` - cartesian coordinates of vertex, include `elevation`
    - `gcs` - geographic coordinate system - latitude and longitude of vertex
    - `elevation` - elevation of point above sea level (or below when negative)
    - `value` - custom property of vertex - for instance water

# Note
- `gcs` are in degress, where:
    - `lat` is in range `[-90, 90]`
    - `lon` is in range `(-180, 180]`

See also: [`HyperGraph`](@ref)
"""
mutable struct SphereGraph <: HyperGraph
    graph::MG.MetaGraph
    radius::Real
    vertex_count::Integer
    interior_count::Integer
    hanging_count::Integer
end

"""
    SphereGraph(radius)

Construct a `SphereGraph` with radius `radius`.
"""
function SphereGraph(radius::Real)::SphereGraph
    graph = MG.MetaGraph()
    SphereGraph(graph, radius, 0, 0, 0)
end

"""
    SphereGraph()

Construct a `SphereGraph` with `radius=6371000` - Earth's radius.
"""
SphereGraph() = SphereGraph(6371000)::SphereGraph

function show(io::IO, g::SphereGraph)
    vs = g.vertex_count
    ins = g.interior_count
    hs = g.hanging_count
    es = length(edges(g))
    r = g.radius
    print(
        io,
        "SphereGraph with ($(vs) vertices), ($(ins) interiors), ($(hs) hanging nodes), ($(es) edges) and (radius $(r))",
    )
end

# -----------------------------------------------------------------------------
# ------ Functions specific for SphereGraph -----------------------------------
# -----------------------------------------------------------------------------

function cartesian_to_spherical(coords::AbstractVector{<:Real})
    x, y, z = coords
    r = norm(coords[1:3])
    lat = r !=0 ? -acosd(z / r) + 90.0 : 0
    lon = atand(y, x)
    [r, lat, lon]
end

function spherical_to_cartesian(coords::AbstractVector{<:Real})
    r, lat, lon = coords
    r .* [cosd(lon) * cosd(lat), sind(lon) * cosd(lat), sind(lat)]
end

"""
    gcs(g, v)

Return latitude and longtitude of vertex `v` (in geographic coordinate system).

See also: [`SphereGraph`](@ref)
"""
gcs(g::SphereGraph, v::Integer) = uv(g, v)[[2,1]]
lat(g::SphereGraph, v::Integer) = uv(g, v)[2]
lon(g::SphereGraph, v::Integer) = uv(g, v)[1]

"Return vector `[r, lat, lon]` with spherical coordinates of vertex `v`."
function get_spherical(g::SphereGraph, v::Integer)
    coords = gcs(g, v)
    elevation = MG.get_prop(g.graph, v, :elevation)
    vcat(g.radius + elevation, coords)
end

"Recalculate cartesian coordinates of vertex `v` using spherical."
function recalculate_cartesian!(g::SphereGraph, v::Integer)
    spherical = get_spherical(g, v)
    coords = spherical_to_cartesian(spherical)
    MG.set_prop!(g.graph, v, :xyz, coords)
end

# -----------------------------------------------------------------------------
# ------ Methods for HyperGraph functions -------------------------------------
# -----------------------------------------------------------------------------

function get_elevation(g::SphereGraph, v::Integer)
    elevation = MG.get_prop(g.graph, v, :elevation)::Real
    return elevation
end


function project!(g::SphereGraph, v, elevation)
    MG.set_prop!(g.graph, v, :elevation, elevation)
    recalculate_cartesian!(g, v)
end

uv(g::SphereGraph, v::Integer) = MG.get_prop(g.graph, v, :uv)

function get_value_cartesian(g::SphereGraph, v::Integer)
    coords = get_spherical(g, v)
    coords[1] += get_value(g, v)
    return spherical_to_cartesian(coords)
end

"""
distance(g, v1, v2)

Returns the distance between two vertices of the hypergraph.

#Note:
 - This method is used to compute the longest edge

"""
distance(g::SphereGraph, v1, v2) = norm(uv(g, v2) - uv(g, v1))

