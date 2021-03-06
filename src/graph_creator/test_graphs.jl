"Return graph on which production P1 should run."
function p1_graph_1()
    g = MetaGraph()

    add_hanging!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 0.0, 1.0)
    add_meta_vertex!(g, 0.5, 1.0, -1.0)

    add_interior!(g, 1, 2, 3, true)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, true)
    add_meta_edge!(g, 3, 1, false)

    return g
end

"Return graph on which production P2 should run."
function p1_graph_2()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 0.0, 1.0)
    add_meta_vertex!(g, 0.5, 1.0, -1.0)

    add_interior!(g, 1, 2, 3, true)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, false)
    add_meta_edge!(g, 3, 1, false)

    return g
end

"Return graph on which production P2 should run."
function p2_graph_1()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)

    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, true)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 3, 4, false)

    return g
end

"Return graph on which production P3 should run."
function p3_graph_1()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 0.0, 1.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)

    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, true)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 3, 4, false)

    return g
end

"Return graph on which production P3 should run."
function p3_graph_2()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 0.0, 1.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)

    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, false)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 3, 4, false)

    return g
end

"Return graph on which production P4 should run."
function p4_graph_1()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)
    add_hanging!(g, 1.5, 0.5, 0.0)


    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 3, false)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 4, 2, false)
    add_meta_edge!(g, 2, 5, false)
    add_meta_edge!(g, 5, 3, false)

    return g
end

"Return graph on which production P4 should run."
function p4_graph_2()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)
    add_hanging!(g, 0.5, 0.5, 0.0)


    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 4, 2, false)
    add_meta_edge!(g, 2, 3, false)
    add_meta_edge!(g, 5, 3, false)
    add_meta_edge!(g, 1, 5, false)

    return g
end

"Return graph on which production P5 should run."
function p5_graph_1()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_hanging!(g, 0.5, 0.5, 0.0)
    add_hanging!(g, 1.5, 0.5, 0.0)


    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 2, true)
    add_meta_edge!(g, 2, 5, false)
    add_meta_edge!(g, 5, 3, false)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 4, 3, false)

    return g
end

"Return graph on which production P5 should run."
function p5_graph_2()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_hanging!(g, 0.5, 0.5, 0.0)
    add_hanging!(g, 1.5, 0.5, 0.0)


    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 5, false)
    add_meta_edge!(g, 5, 3, false)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 4, 3, false)

    return g
end

"Return graph on which production P6 should run."
function p6_graph_1()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)
    add_meta_vertex!(g, 2.0, 0.0, 0.0)
    add_meta_vertex!(g, 1.0, 1.0, 0.0)
    add_hanging!(g, 1.0, 0.0, 0.0)
    add_hanging!(g, 1.5, 0.5, 0.0)
    add_hanging!(g, 0.5, 0.5, 0.0)

    add_interior!(g, 1, 2, 3, false)

    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 4, 2, false)
    add_meta_edge!(g, 2, 5, false)
    add_meta_edge!(g, 5, 3, false)
    add_meta_edge!(g, 3, 6, false)
    add_meta_edge!(g, 6, 1, false)

    return g
end
