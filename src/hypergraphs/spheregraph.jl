using Graphs
using MetaGraphs
using LinearAlgebra

"""
`HyperGraph` whose vertices are on sphere with radius `r`.

Can represent Earth's surface where elevation above (or below) sea level is
set using `elevation` property.

# Note:
Vertices with type `vertex` have following poperties:
- `x`, `y`, `z` - cartesian coordinates of vertex, include `elevation`
- `lat`, `lon` - latitude and longitude of vertex
- `elevation` - elevation of point above sea level (or below when negative)
- `value` - custom property of vertex - for instance water level

See also: [`HyperGraph`](@ref)
"""
mutable struct SphereGraph <: HyperGraph
    graph::MetaGraph
    radius::Real
    vertices_count::Integer
    interior_count::Integer
    hanging_count::Integer
    valued_vertices::Integer
end

"""
    SphereGraph()
    SphereGraph(radius)

Create SphereGraph.

`radius` is radius of a sphere and defaults to 6371000 - Earth' radius.
"""
function SphereGraph end

function SphereGraph(radius)
    graph = MetaGraph()
    SphereGraph(graph, radius, 0, 0, 0 ,0)
end

SphereGraph() = SphereGraph(6371000)     # Earth's radius

function add_vertex!(g::SphereGraph, coords::Vector{<:Real})
    if length(coords) == 2
    elseif length(coords) == 3
end

function add_hanging!(g::SphereGraph)
end

function add_interior!()
end

function add_edge!()
end

function vertices_with_type()
end

function hanging_nodes()
end

function normal_vertices()
end

function interiors()
end

function get_hanging_node_between()
end

function xyz_coords()
end

function lat_len()
end

function is_hanging()
end

function is_vertex()
end

function is_interior()
end

function has_value()
end

function is_on_border()
end

function set_border()
end

function edge_length()
end

function set_value()
end

function set_all_values!()
end

function vertex_map()
end

function cartesian_to_spherical(coords::Vector{<:Real})
    x = coords[1]
    y = coords[2]
    z = coords[3]
    r = norm(coords[1:3])
    lat = -acos(z/r) + pi/2.0
    lon = atan(y, x)
    [r, lat, lon]
end

function spherical_to_cartesian(coords::Vector{<:Real})
    r = coords[1]
    lat = -coords[2] + pi/2.0
    lon = coords[3] >= 0 ? coords[3] : coords[3] + 2.0 * pi
    x = r * cos(lon) * sin(lat)
    y = r * sin(lon) * sin(lat)
    z = r * cos(lat)
    [x, y, z]
end
