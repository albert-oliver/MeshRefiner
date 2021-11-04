import Graphsl; const Gr = Graphs
import MetaGraphs; const MG = MetaGraphs
using LinearAlgebra

"""
`HyperGraph` whose vertices are on sphere with radius `radius`.

Can represent Earth's surface where elevation above (or below) sea level is
set using `elevation` property.

# Verticex properties
All properties are the same as in `HyperGraph` except for the following:
- `vertex` type vertices:
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
    graph::MetaGraph
    radius::Real
    vertices_count::Integer
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

function cartesian_to_spherical(coords::Vector{<:Real})
    x = coords[1]
    y = coords[2]
    z = coords[3]
    r = norm(coords[1:3])
    lat = -acos(z / r) + pi / 2.0
    lon = atan(y, x)
    lat = lat * 180 / pi
    lon = lon * 180 / pi
    [r, lat, lon]
end

function spherical_to_cartesian(coords::Vector{<:Real})
    r = coords[1]
    lat = coords[2] * pi / 180
    lon = coords[3] * pi / 180
    lat = -lat + pi / 2.0
    lon = lon >= 0 ? lon : lon + 2.0 * pi
    x = r * cos(lon) * sin(lat)
    y = r * sin(lon) * sin(lat)
    z = r * cos(lat)
    [x, y, z]
end

"""
    gcs(g, v)

Return latitude and longtitude of vertex `v` (in geographic coordinate system).

See also: [`SphereGraph`](@ref)
"""
function gcs(g::SphereGraph, v) = MG.get_prop(g.graph, v, :gcs)

"Return vector `[r, lat, lon]` with spherical coordinates of vertex `v`."
function get_spherical(g::SphereGraph, v)
    elevation = MG.get_prop(g, v, :elevation)
    vcat([g.radius + elevation], )
end

"Recalculate cartesian coordinates of vertex `v` using spherical."
function recalculate_cartesian!(g::SphereGraph, v)
    spherical = get_spherical(g, v)
    xyz = spherical_to_cartesian(spherical)
    MG.set_prop!(g.graph, v, :xyz, xyz)
end

"Recalculate spherical coordinates of vertex `v` using cartesian."
function recalculate_spherical!(g::SphereGraph, v)
    xyz = xyz(g, v)
    spherical = cartesian_to_spherical(xyz)
    MG.set_prop!(g.graph, v, :elevation, spherical[1] - g.radius)
    MG.set_prop!(g.graph, v, :gcs, spherical[2:3])
end

function add_vertex!(g::SphereGraph, coords::Vector{Real}; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g.graph, nv(g), :type, "vertex")
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g.graph, nv(g), :xyz, coords[1:3])
    recalculate_spherical(g)
    g.vertices_count += 1
    return nv(g)
end

function add_vertex!(g::SphereGraph, coords::Vector{Real}, elevation::Real; value::Real = 0.0)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g, nv(g), :type, "vertex")
    MG.set_prop!(g.graph, nv(g), :value, value)
    MG.set_prop!(g, nv(g), :gcd, coords[1:2])
    MG.set_prop!(g, nv(g), :elevation, elevation)
    recalculate_cartesian(g)
    g.vertices_count += 1
    return nv(g)
end

function add_hanging!(g::SphereGraph, v1, v2)
    Gr.add_vertex!(g.graph)
    MG.set_prop!(g, nv(g), :type, "hanging")
    MG.set_prop!(g.graph, nv(g), :value, 0.0)
    xyz = (xyz(g, v1) + xyz(g, v2)) / 2.0
    MG.set_prop!(g.graph, nv(g), :xyz, xyz)
    MG.set_prop!(g.graph, nv(g), :v1, v1)
    MG.set_prop!(g.graph, nv(g), :v2, v2)
    recalculate_spherical(g)
    g.hanging_count += 1
    return nv(g)
end

function get_elevation(g::SphereGraph, v) MG.get_prop(g, v, :elevation)
function set_elevation!(g::SphereGraph, v, elevation)
    MG.set_prop!(g, v, :elevation, elevation)
    recalculate_cartesian!(g, v)
end
