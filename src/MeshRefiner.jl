module MeshRefiner

include("io.jl")
include("graphs/example_graphs.jl")
include("graphs/test_graphs.jl")
include("visualization/draw_makie.jl")
include("visualization/draw_graphplot.jl")
include("transformations/p1.jl")
include("transformations/p2.jl")
include("transformations/p3.jl")
include("transformations/p4.jl")
include("transformations/p5.jl")
include("transformations/p6.jl")
include("utils.jl")
include("adaptation/adapt_terrain.jl")
include("adaptation/adapt_fun.jl")
include("derivations/der.jl")

using LightGraphs
using MetaGraphs
using LinearAlgebra
using Statistics
using Compose
import Cairo, Fontconfig

end # module
