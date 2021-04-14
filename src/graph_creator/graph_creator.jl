"Module that contains functions that create graphs for various purposes."
module GraphCreator

export
    simple_graph,
    full_graph_1,
    sim_values_1,
    regular_flat_mesh,
    mesh_hat_fun,
    hat_fun,
    block_fun

include("functions.jl")
include("example_graphs.jl")
include("test_graphs.jl")
include("full_graphs.jl")
include("adapted_graphs.jl")

end
