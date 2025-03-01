"Module that is responsible for all IO operations, like loading terrain data
from file."
module ProjectIO

using ..Utils
using ..Visualization
using MeshGraphs

export
    load_data,
    load_heightmap,
    saveGML,
    export_obj,
    export_simulation,
    load_vtu

using Printf
using GLMakie

import LightXML as XML
import Images
import ArchGDAL as AG
import MetaGraphs as MG
import Graphs as Gr

include("persist_graphml.jl")
include("persist_matrix.jl")

"Splits filename to base and extension"
function split_filename(filename)
    splitted = split(filename, ".")
    file_base = join(splitted[1:length(splitted)-1])
    extenstion = splitted[length(splitted)]
    return file_base, extenstion
end

"Load terrain data (in bytes) as `TerrainMap`"
function load_data(filename, dims, type=Float64)::TerrainMap
    bytes_data =  open(f->read(f), filename)
    nicer_data = reinterpret(Int16, bytes_data)
    dim = Int(sqrt(size(nicer_data)[1]))
    matrix = reshape(nicer_data, (dim, dim))
    as_type =  map(x -> type(x), matrix)
    scale = maximum(as_type) - minimum(as_type)
    offset = minimum(as_type)
    # normalized is in range 1.0 to 2.0
    normalized = map(x -> (x - offset) / scale, as_type + 1.0)
    return TerrainMap(reversed, dims[1], dims[2], scale)
end

"""
    load_heightmap(filename, dims, scale=1.0, offset=0.0, type=Float64)

Load heighmap as `TerrainMap`.

# Arguments
- `filename::String`: path to file containing heightmap.
- `dims::Array{<:Real, 1}`: size of terrain as 2-element array [x, y]. **Note: **
 it can't be too small (many times smaller than heighmap size) as it may lead to
 problems with float representation (`==`).
- `scale::Real=1.0`: Pixels in heightmap are in range [0, 1]. To calculate real
 height it is then multiplied by `scale`.
- `offset::Real=0,0`: it is added to previous result in order to calculate real
 height.
- `type::Type=Float64`: How pixels will be represented in returned struct.

See also [`TerrainMap`](@ref)
"""
function load_heightmap(filename, dims, scale=1.0, offset=0.0, type=Float64)::TerrainMap
    img = Images.load(filename)
    grayscale = Images.Gray.(img)
    f(x) = type(Images.gray(x) + 1)
    # mapped is in range 1.0 to 2.0
    mapped = map(f, grayscale)
    println(maximum(mapped), " ", minimum(mapped))
    reversed = reverse(mapped, dims=1)
    return TerrainMap(reversed, dims[1], dims[2], scale, offset)
end

"Save graph `g` as GML file."
function saveGML(g, filename)
    open(filename, "w") do io
        write(io, "graph [\n")
        write(io, "\tdirected 0\n")
        if typeof(g) == FlatGraph
            write(io, "\ttype FlatGraph\n")
        elseif typeof(g) == SphereGraph
            write(io, "\ttype SphereGraph\n")
            write(io, @sprintf("\tradius %s\n"), string(g.radius))
        end
        write(io, @sprintf("\tvertex_count %s\n", string(g.vertex_count)))
        write(io, @sprintf("\tinterior_count %s\n", string(g.interior_count)))
        write(io, @sprintf("\thanging_counts %s\n", string(g.hanging_count)))

        for v in 1:MG.nv(g.graph)
            write(io, "\tnode [\n")

            write(io, @sprintf("\t\tid %d\n", v))
            for pair in MG.props(g.graph, v)
                write(io, @sprintf("\t\t%s %s\n", string(pair[1]), string(pair[2])))
            end

            write(io, "\t]\n")
        end

        for e in MG.edges(g.graph)
            write(io, "\tedge [\n")

            write(io, @sprintf("\t\tsource %d\n", Gr.src(e)))
            write(io, @sprintf("\t\ttarget %d\n", Gr.dst(e)))
            for pair in MG.props(g.graph, e)
                write(io, @sprintf("\t\t%s %s\n", string(pair[1]), string(pair[2])))
            end

            write(io, "\t]\n")
        end

        write(io, "]\n")
    end
    return nothing
end

"Export graph as OBJ. If flag `include_fun` is set also export function that mesh
approximates (requires `value` property set)."
function export_obj(
    g,
    filename;
    include_terrain=true,
    include_fun = false,
    fun_seperate_file = false,
    function_ϵ = 1e-10,
    z_scale = 1.0
)
    v_id = 1
    if include_terrain
        open(filename, "w") do io
            t_map = Dict()
            for v in normal_vertices(g)
                x, y, z = xyz(g, v)
                write(io, @sprintf("v %f %f %f\n", x, y, z * z_scale))
                t_map[v] = v_id
                v_id += 1
            end

            # TODO remove
            for v in hanging_nodes(g)
                x, y, z = xyz(g, v)
                write(io, @sprintf("v %f %f %f\n", x, y, z * z_scale))
                t_map[v] = v_id
                v_id += 1
            end

            for i in interiors(g)
                v1, v2, v3 = interiors_vertices(g, i)
                write(io, @sprintf("f %d %d %d\n", t_map[v1], t_map[v2], t_map[v3]))
            end
        end
    end

    open_type = "a"
    if fun_seperate_file || !include_terrain
        file_base, ext = split_filename(filename)
        filename = join([file_base, "_fun.", ext])
        open_type = "w"
        v_id = 1
    end
    open(filename, open_type) do io
        if include_fun
            fun_map = Dict()
            vertices, faces = function_mesh(g; ϵ = function_ϵ)
            for (i, (x, y, z)) in enumerate(eachrow(vertices))
                write(io, @sprintf("v %f %f %f\n", x, y, z * z_scale))
                fun_map[i] = v_id
                v_id += 1
            end
            for (v1, v2, v3) in eachrow(faces)
                write(
                    io,
                    @sprintf(
                        "f %d %d %d\n",
                        fun_map[v1],
                        fun_map[v2],
                        fun_map[v3]
                    )
                )
            end
        end
    end
end

"""
    export_simulation(g, values; filename="sim.mp4", fps=24)

Export simulation as video. Values is matrix returned from [`simulate`](@ref).
"""
function export_simulation(g, values;
    filename="sim.mp4",
    fps=24,
    transparent_fun=false,
    shading_fun=true,
    show_axis=false,
    z_scale=1,
    function_ϵ=1e-10)
    set_all_values!(g, values[1,:])
    scene = draw_makie(g; include_fun=false, show_axis=show_axis, z_scale=z_scale)
    vertices, faces = function_mesh(g, z_scale=z_scale, ϵ=function_ϵ)

    # Makie can't draw empty meshes - so if it should I just draw single trinagle
    if isempty(faces)
        faces = [1 2 3]
    end
    current_mesh = mesh!(vertices, faces, color=:lightblue, shading=shading_fun, transparency=transparent_fun)

    record(scene, filename, 1:size(values)[1]; framerate=fps) do i
        set_all_values!(g, values[i,:])
        vertices, faces = function_mesh(g; z_scale=z_scale, ϵ=function_ϵ)
        current_mesh[1] = vertices

        # Same here
        if !isempty(faces)
            current_mesh[2] = faces
        else
            current_mesh[2] = [1 2 3]
        end
    end
end

"""
    load_tiff(filename)

Loads tiff file as TerrainMap.
"""
function load_tiff(filename::String)::TerrainMap
    dataset = AG.readraster(filename)
    band = AG.getband(dataset, 1)
    gt = AG.getgeotransform(dataset)
    start_x = gt[1]
    start_y = gt[4]
    step_x = gt[2]
    step_y = gt[6]
    nx = AG.width(dataset)
    ny = AG.height(dataset)
    M = transpose(band)
    if step_x < 0
        start_x = start_x + (nx-1) * step_x
        step_x = -step_x
        M = reverse(M, dims=2)
    end
    if step_y < 0
        start_y = start_y + (ny-1) * step_y
        step_y = -step_y
        M = reverse(M, dims=1)
    end
    TerrainMap(M, start_x, start_y, step_x, step_y, nx, ny)
end

"""
    load_vtu(filename)

Loads vtu file as graph.
"""
function load_vtu(filename::String)::FlatGraph
    xdoc = XML.parse_file(filename)
    xroot = XML.root(xdoc)
    piece = xroot["UnstructuredGrid"][1]["Piece"][1]
    points_count = parse(Int64, XML.attribute(piece, "NumberOfPoints"))
    cells_count = parse(Int64, XML.attribute(piece, "NumberOfCells"))

    points_node = piece["Points"][1]["DataArray"][1]
    parse_float(x) = parse(Float64, x)
    points = reshape(map(parse_float, split(string(first(XML.child_nodes(points_node))))), 3, :)

    cells_node = piece["Cells"][1]["DataArray"][1]
    parse_int(x) = parse(Int64, x)
    cells = reshape(map(parse_int, split(string(first(XML.child_nodes(cells_node))))), 3, :)
    cells = map(x -> x + 1, cells)

    XML.free(xdoc)

    # Create graph
    g = FlatGraph()

    for point in eachcol(points)
        add_vertex!(g, [point[1], point[2], point[3]])
    end

    for cell in eachcol(cells)
        add_edge!(g, cell[1], cell[2])
        add_edge!(g, cell[1], cell[3])
        add_edge!(g, cell[2], cell[3])
        add_interior!(g, cell[1], cell[2], cell[3])
    end

    return g
end

end
