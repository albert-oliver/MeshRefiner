"Return graph on which production P1 should run."
function p1_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 1.0, 0.0])
    add_vertex!(g, [0.0, -1.0, 0.0])
    add_hanging!(g, 1, 2, [0.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 0.0, 1.0])
    add_vertex!(g, [0.5, 1.0, -1.0])

    add_interior!(g, 3, 4, 5; refine=true)

    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5; boundary=true)
    add_edge!(g, 5, 3)

    return g
end

"Return graph on which production P1 should run."
function p1_graph_2()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 0.0, 1.0])
    add_vertex!(g, [0.5, 1.0, -1.0])

    add_interior!(g, 1, 2, 3; refine=true)

    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)

    return g
end

"Return graph on which production P2 should run."
function p2_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_hanging!(g, 1, 3, [1.0, 0.0, 0.0])

    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 1, 4)
    add_edge!(g, 3, 4)

    return g
end

"Return graph on which production P3 should run."
function p3_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [0.0, 1.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_hanging!(g, 1, 3, [1.0, 0.0, 0.0])

    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 1, 4)
    add_edge!(g, 3, 4)

    return g
end

"Return graph on which production P3 should run."
function p3_graph_2()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [0.0, 1.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_hanging!(g, 1, 3, [1.0, 0.0, 0.0])

    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 3, 4)

    return g
end

"Return graph on which production P4 should run."
function p4_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_hanging!(g, 1, 2, [1.0, 0.0, 0.0])
    add_hanging!(g, 2, 3, [1.5, 0.5, 0.0])


    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 4, 2)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 3)

    return g
end

"Return graph on which production P4 should run."
function p4_graph_2()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_hanging!(g, 1, 2, [1.0, 0.0, 0.0])
    add_hanging!(g, 1, 3, [0.5, 0.5, 0.0])


    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 4)
    add_edge!(g, 4, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 5, 3)
    add_edge!(g, 1, 5)

    return g
end

"Return graph on which production P5 should run."
function p5_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_hanging!(g, 1, 3, [0.5, 0.5, 0.0])
    add_hanging!(g, 2, 3, [1.5, 0.5, 0.0])

    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 4, 3)

    return g
end

"Return graph on which production P5 should run."
function p5_graph_2()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_hanging!(g, 1, 3, [0.5, 0.5, 0.0])
    add_hanging!(g, 2, 3, [1.5, 0.5, 0.0])


    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 2)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 3)
    add_edge!(g, 1, 4)
    add_edge!(g, 4, 3)

    return g
end

"Return graph on which production P6 should run."
function p6_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])
    add_vertex!(g, [2.0, 0.0, 0.0])
    add_vertex!(g, [1.0, 1.0, 0.0])
    add_hanging!(g, 1, 2, [1.0, 0.0, 0.0])
    add_hanging!(g, 2, 3, [1.5, 0.5, 0.0])
    add_hanging!(g, 1, 3, [0.5, 0.5, 0.0])

    add_interior!(g, 1, 2, 3)

    add_edge!(g, 1, 4)
    add_edge!(g, 4, 2)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 3)
    add_edge!(g, 3, 6)
    add_edge!(g, 6, 1)

    return g
end
