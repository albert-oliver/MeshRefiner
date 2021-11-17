import Graphs; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
using LinearAlgebra

# -----------------------------------------------------------------------------
# ------ SphereGraph type definition and constructors -------------------------
# -----------------------------------------------------------------------------

"""
`SphereGraph` is a`HyperGraph` whose vertices are on sphere with radius
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
    SphereGraph()
    SphereGraph(radius)

Create SphereGraph.

`radius` is radius of a sphere and defaults to 6371000 - Earth's radius.
"""
function SphereGraph end

function SphereGraph(radius)
    graph = MG.MetaGraph()
    SphereGraph(graph, radius, 0, 0, 0)
end

SphereGraph() = SphereGraph(6371000)     # Earth's radius

# -----------------------------------------------------------------------------
# ------ Functions specific for SphereGraph -----------------------------------
# -----------------------------------------------------------------------------

function cartesian_to_spherical(coords)
    x, y, z = coords
    r = norm(coords[1:3])
    lat = r !=0 ? -acosd(z / r) + 90.0 : 0
    lon = atand(y, x)
    [r, lat, lon]
end

function spherical_to_cartesian(coords)
    r, lat, lon = coords
    r .* [cosd(lon) * cosd(lat), sind(lon) * cosd(lat), sind(lat)]
end

"""
    gcs(g, v)

Return latitude and longtitude of vertex `v` (in geographic coordinate system).

See also: [`SphereGraph`](@ref)
"""
gcs(g::SphereGraph, v) = MG.get_prop(g.graph, v, :gcs)
lat(g::SphereGraph, v) = gcs(g, v)[1]
lon(g::SphereGraph, v) = gcs(g, v)[2]

"Return vector `[r, lat, lon]` with spherical coordinates of vertex `v`."
function get_spherical(g::SphereGraph, v)
    coords = gcs(g, v)
    elevation = MG.get_prop(g.graph, v, :elevation)
    vcat([g.radius + elevation], coords)
end

"Recalculate cartesian coordinates of vertex `v` using spherical."
function recalculate_cartesian!(g::SphereGraph, v)
    spherical = get_spherical(g, v)
    coords = spherical_to_cartesian(spherical)
    MG.set_prop!(g.graph, v, :xyz, coords)
end

"Recalculate spherical coordinates of vertex `v` using cartesian."
function recalculate_spherical!(g::SphereGraph, v)
    coords = xyz(g, v)
    spherical = cartesian_to_spherical(coords)
    MG.set_prop!(g.graph, v, :elevation, spherical[1] - g.radius)
    MG.set_prop!(g.graph, v, :gcs, spherical[2:3])
end

# -----------------------------------------------------------------------------
# ------ Methods for HyperGraph functions -------------------------------------
# -----------------------------------------------------------------------------

function add_vertex!(g::SphereGraph, coords; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, VERTEX)
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g.graph, nv(g), :xyz, coords[1:3])
    recalculate_spherical!(g, nv(g))
    g.vertex_count += 1
    return nv(g)
end

function add_vertex!(g::SphereGraph, coords, elevation::Real; value::Real = 0.0)
    lat = coords[1]
    if lat < -90 || lat > 90
        throw(DomainError(lat, "Latitude has to be in range [-90, 90]"))
    end
    lon = -(mod((-coords[2] + 180), 360) - 180)     # moves lon to range (-180, 180]

    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, VERTEX)
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g.graph, nv(g), :gcs, [lat, lon])
    MG.set_prop!(g.graph, nv(g), :elevation, elevation)
    recalculate_cartesian!(g, nv(g))
    g.vertex_count += 1
    return nv(g)
end

get_elevation(g::SphereGraph, v) = MG.get_prop(g.graph, v, :elevation)
function set_elevation!(g::SphereGraph, v, elevation)
    MG.set_prop!(g.graph, v, :elevation, elevation)
    recalculate_cartesian!(g, v)
end
