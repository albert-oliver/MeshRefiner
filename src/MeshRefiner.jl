module MeshRefiner

include("utils.jl")
include("transformations/transformations.jl")
include("adaptation/adaptation.jl")
include("graph_creator/graph_creator.jl")
include("visualization/visualization.jl")
include("io.jl")
include("simulation/sim.jl")

export
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

end # module
