"Module defining hypergraph type and related functions"
module HyperGraphs

using MetaGraphs
using Graphs

abstract type HyperGraph end

include("flatgraph.jl")
include("spheregraph.jl")

end # module
