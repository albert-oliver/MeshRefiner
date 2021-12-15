module MeshRefiner

include("hypergraphs/hypergraphs.jl")
include("utils.jl")
include("adaptation/adaptation.jl")
include("transformations/transformations.jl")
include("graph_creator/graph_creator.jl")
include("visualization/visualization.jl")
include("io/io.jl")
include("simulation/sim.jl")

using .HyperGraphs
using .Utils
using .Transformations
using .Adaptation
using .GraphCreator
using .Visualization
using .ProjectIO
using .Simulation

export
    # HyperGraphs
    SphereGraph,
    FlatGraph,

    # Terrain adaptation
    generate_terrain_mesh,
    adapt_terrain!,
    TerrainMap,
    check_mesh,

    # Function adaptation
    match_to_fun!,
    adapt_fun!,

    # IO
    load_data,
    load_heightmap,
    saveGML,
    export_obj,
    export_simulation,

    # Simulation
    simulate!,

    # Visualization
    draw_makie,
    draw_graphplot,

    # Ready graphs and water functions
    simple_graph,
    full_graph_1,
    sim_values_1,
    regular_flat_mesh,
    hat_fun,
    block_fun

"""
    adapt_terrain!(g, terrain, ϵ, max_iters)

Adapt graph `g` to terrain map `terrain`. Stop when error is lesser than ϵ, or
after `max_iters` iterations.

See also: [`generate_terrain_mesh`](@ref)
"""
function adapt_terrain!(
    g::HyperGraph,
    terrain::TerrainMap,
    params,
    max_iters::Integer,
)
    for i = 1:max_iters
        println("Iteration ", i)
        to_refine = Adaptation.mark_for_refinement(g, terrain, params::Adaptation.RefinementParameters)
        if isempty(to_refine)
            break
        end
        for interior in to_refine
            set_refine!(g, interior)
        end
        refine!(g, terrain)
        if has_hanging_nodes(g)
            println(
                "ERROR: Hanging nodes in graph. Transformations don't work correctly",
            )
            break
        end
        # adjust_elevations!(g, terrain)
    end
    return g
end

"""
    generate_terrain_mesh(terrain, ϵ, max_iters=20)

Generate graph (terrain mesh), based on terrain map `terrain`.

See also: [`adapt_terrain`](@ref)
"""
function generate_terrain_mesh(terrain::TerrainMap, params::Adaptation.RefinementParameters, max_iters::Integer = 20)
    g = Adaptation.initial_graph(terrain)
    adapt_terrain!(g, terrain, params, max_iters)
    # scale_elevations!(g, terrain)
    return g
end

end # module
