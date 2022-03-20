include("../src/MeshRefiner.jl")

using Compose
import Cairo, Fontconfig, MeshGraphs



"Mark traingles to refine (seperated by space) and run transformations.
Graphs are saved as png in `graphs/`"
function interactive_test()
    g = MeshRefiner.simple_graph()
    i = 1
    while true
        draw(PNG(string("examples/graphs/testgraph", i, ".png"), 16cm, 16cm), MeshRefiner.draw_graphplot(g; vid=true))
        print("To refine (q to quit): ")
        s = readline()
        if (s == "q")
            break
        end
        splitted = split(s)
        for svertex in splitted
            v = parse(Int64, svertex)
            MeshGraphs.set_refine!(g, v)
        end
        MeshRefiner.Transformations.refine!(g; log=true)
        i += 1
    end
end
