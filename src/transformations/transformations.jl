"Module that contains all transformations responsible for breaking marked
traingles and removing hanging nodes."
module Transformations

using ..Adaptation
using ..HyperGraphs
using ..Utils

export
    transform_p1!,
    transform_p2!,
    transform_p3!,
    transform_p4!,
    transform_p5!,
    transform_p6!,
    refine!

include("rivara/p1.jl")
include("rivara/p2.jl")
include("rivara/p3.jl")
include("rivara/p4.jl")
include("rivara/p5.jl")
include("rivara/p6.jl")

"""
    run_for_all_triangles!(g, fun; log=false)

Run function `fun(g, i)` on all interiors `i` of graph `g`
"""
function run_for_all_triangles!(g::HyperGraph, interior_set, fun, terrain_map::TerrainMap; log=false)
    ran = false
    for v in interior_set
        ex, new_node = fun(g, v)

        if ex
            if !isnothing(new_node)
                Adaptation.adjust_elevations!(g, new_node, terrain_map)
            end

            if log
                println("Executed: ", String(Symbol(fun)), " on ", v , [uv(g, kk) for kk in interiors_vertices(g, v)])
            end
        end
        ran |= ex
    end
    return ran
end

"""
    run_transformations!(g; log=false)

Execute all transformations (P1-P6) on all interiors of graph `g`. Stop when no
more transformations can be executed.

`log` flag tells wheter to log what transformation was executed on which vertex
"""
function refine!(g::HyperGraph, terrain_map::TerrainMap; log=false)
    while true
        ran = false
        interior_set = collect(interiors(g))
        ran |= run_for_all_triangles!(g, interior_set, transform_p1!, terrain_map; log=log)
        ran |= run_for_all_triangles!(g, interior_set, transform_p2!, terrain_map; log=log)
        ran |= run_for_all_triangles!(g, interior_set, transform_p3!, terrain_map; log=log)
        ran |= run_for_all_triangles!(g, interior_set, transform_p4!, terrain_map; log=log)
        ran |= run_for_all_triangles!(g, interior_set, transform_p5!, terrain_map; log=log)
        ran |= run_for_all_triangles!(g, interior_set, transform_p6!, terrain_map; log=log)
        if !ran
            return false
        end
    end
end

# TODO = subidvide
"""
    subdivie!(g, iters)

Subdivides graph `g`, `iters` times.

```text
v                 v
|\\                |\\
| \\               | \\
|  \\      =>      v--v
|   \\             |\\ |\\
|    \\            | \\| \\
v-----v           v--v--v
```
"""
function subdivie(g::HyperGraph, iters)
    for _ in 1:iters

    end
end

function points_in_subdivided(g::HyperGraph, interior, iters)

end

end
