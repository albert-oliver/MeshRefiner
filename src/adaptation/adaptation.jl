module Adaptation

export adapt_fun!, adapt_terrain!, initial_graph, mark_for_refinement, run_transformations!, adjust_heights

include("adapt_fun.jl")
include("adapt_terrain.jl")

end
