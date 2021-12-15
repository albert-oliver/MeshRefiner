"Most important module responsible for adaptaion of the mesh."
module Adaptation

using ..HyperGraphs
using ..Utils
using ..Transformations

export
    adapt_fun!,
    adapt_terrain!,
    generate_terrain_mesh,
    match_to_fun!,
    check_mesh
    
include("adapt_fun.jl")
include("adapt_terrain.jl")

end
