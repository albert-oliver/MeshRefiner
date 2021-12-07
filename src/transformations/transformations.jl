"Module that contains all transformations responsible for breaking marked
traingles and removing hanging nodes."
module Transformations

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
function run_for_all_triangles!(g::HyperGraph, fun; log=false)
    ran = false
    for v in interiors(g)
        ex = fun(g, v)
        if ex && log
            println("Executed: ", String(Symbol(fun)), " on ", v)
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
function refine!(g::HyperGraph; log=false)
    while true
        ran = false
        ran |= run_for_all_triangles!(g, transform_p1!; log=log)
        ran |= run_for_all_triangles!(g, transform_p2!; log=log)
        ran |= run_for_all_triangles!(g, transform_p3!; log=log)
        ran |= run_for_all_triangles!(g, transform_p4!; log=log)
        ran |= run_for_all_triangles!(g, transform_p5!; log=log)
        ran |= run_for_all_triangles!(g, transform_p6!; log=log)
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
