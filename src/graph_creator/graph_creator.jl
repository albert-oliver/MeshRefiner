"Module that contains functions that create graphs for various purposes."
module GraphCreator

export
    simple_graph,
    example_graph_1,
    example_graph_2,
    example_graph_3,
    full_graph_1

include("example_graphs.jl")
include("test_graphs.jl")
include("full_graphs.jl")

end
