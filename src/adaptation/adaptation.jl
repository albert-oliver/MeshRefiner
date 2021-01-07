module Adaptation

export
    adapt_fun!,
    adapt_terrain!,
    generate_terrain_mesh,

ϕ1(x, y) = x
ϕ2(x, y) = y
ϕ3(x, y) = 1 - x - y

include("adapt_fun.jl")
include("adapt_terrain.jl")

end
