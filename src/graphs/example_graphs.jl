function example_graph_1()
    g = MetaGraph()

    # vertices
    add_meta_vertex!(g, 2.0, 0.0, 0.0)  # 1
    add_meta_vertex!(g, 0.0, 2.0, 0.0)  # 2
    add_meta_vertex!(g, 0.0, 9.0, 0.0)  # 3
    add_meta_vertex!(g, 4.5, 11.0, 0.0) # 4
    add_meta_vertex!(g, 8.5, 8.0, 0.0)  # 5
    add_meta_vertex!(g, 9.0, 3.5, 0.0)  # 6
    add_meta_vertex!(g, 4.5, 1.0, 0.0)  # 7

    # interiors
    add_interior!(g, 1, 2, 7, true)
    add_interior!(g, 2, 3, 7, false)
    add_interior!(g, 3, 4, 7, false)
    add_interior!(g, 4, 5, 7, false)
    add_interior!(g, 5, 6, 7, false)

    #edges
    add_meta_edge!(g, 1, 2, false)
    add_meta_edge!(g, 2, 3, false)
    add_meta_edge!(g, 3, 4, false)
    add_meta_edge!(g, 4, 5, false)
    add_meta_edge!(g, 5, 6, false)
    add_meta_edge!(g, 6, 7, false)
    add_meta_edge!(g, 7, 1, false)
    add_meta_edge!(g, 7, 2, false)
    add_meta_edge!(g, 7, 3, false)
    add_meta_edge!(g, 7, 4, false)
    add_meta_edge!(g, 7, 5, false)

    return g
end

function example_graph_2()
    g = MetaGraph()

    # vertices
    add_meta_vertex!(g, 0.0, 0.0, 0.0)  # 1
    add_meta_vertex!(g, 8.0, 0.0, 0.0)  # 2
    add_meta_vertex!(g, 0.0, 4.0, 0.0)  # 3
    add_meta_vertex!(g, 4.0, 4.0, 0.0)  # 4
    add_meta_vertex!(g, 8.0, 4.0, 0.0)  # 5
    add_meta_vertex!(g, 0.0, 6.0, 0.0)  # 6
    add_meta_vertex!(g, 2.0, 6.0, 0.0)  # 7
    add_meta_vertex!(g, 6.0, 6.0, 0.0)  # 8
    add_meta_vertex!(g, 8.0, 6.0, 0.0)  # 9
    add_meta_vertex!(g, 0.0, 8.0, 0.0)  # 10
    add_meta_vertex!(g, 4.0, 8.0, 0.0)  # 11
    add_meta_vertex!(g, 8.0, 8.0, 0.0)  # 12
    add_hanging!(g, 7.0, 5.0, 0.0)  # 13

    # interiors
    add_interior!(g, 1, 2, 4, false)
    add_interior!(g, 1, 3, 4, false)
    add_interior!(g, 2, 4, 5, false)
    add_interior!(g, 3, 6, 7, false)
    add_interior!(g, 3, 4, 7, false)
    add_interior!(g, 4, 7, 8, false)
    add_interior!(g, 4, 5, 8, false)
    add_interior!(g, 5, 9, 13, false)
    add_interior!(g, 8, 9, 13, false)
    add_interior!(g, 6, 7, 10, false)
    add_interior!(g, 7, 10, 11, false)
    add_interior!(g, 7, 8, 11, false)
    add_interior!(g, 8, 11, 12, false)
    add_interior!(g, 8, 9, 12, false)

    #edges
    add_meta_edge!(g, 1, 2, true)
    add_meta_edge!(g, 2, 5, true)
    add_meta_edge!(g, 5, 9, true)
    add_meta_edge!(g, 9, 12, true)
    add_meta_edge!(g, 12, 11, true)
    add_meta_edge!(g, 11, 10, true)
    add_meta_edge!(g, 10, 6, true)
    add_meta_edge!(g, 6, 3, true)
    add_meta_edge!(g, 3, 1, true)
    add_meta_edge!(g, 1, 4, false)
    add_meta_edge!(g, 2, 4, false)
    add_meta_edge!(g, 3, 4, false)
    add_meta_edge!(g, 4, 5, false)
    add_meta_edge!(g, 3, 7, false)
    add_meta_edge!(g, 4, 7, false)
    add_meta_edge!(g, 4, 8, false)
    add_meta_edge!(g, 5, 13, false)
    add_meta_edge!(g, 8, 13, false)
    add_meta_edge!(g, 9, 13, false)
    add_meta_edge!(g, 6, 7, false)
    add_meta_edge!(g, 7, 8, false)
    add_meta_edge!(g, 8, 9, false)
    add_meta_edge!(g, 7, 10, false)
    add_meta_edge!(g, 7, 11, false)
    add_meta_edge!(g, 8, 11, false)
    add_meta_edge!(g, 8, 12, false)

    return g
end

function example_graph_3()
    g = MetaGraph()

    add_meta_vertex!(g, 0.0, 0.0, 0.0)  # 1
    add_meta_vertex!(g, 1.0, 0.0, 0.0)  # 2
    add_meta_vertex!(g, 2.0, 0.0, 0.0)  # 3
    add_meta_vertex!(g, 0.0, 1.0, 0.0)  # 4
    add_meta_vertex!(g, 1.0, 1.0, 0.0)  # 5
    add_meta_vertex!(g, 2.0, 1.0, 0.0)  # 6
    add_meta_vertex!(g, 0.0, 2.0, 0.0)  # 7
    add_meta_vertex!(g, 1.0, 2.0, 0.0)  # 8
    add_meta_vertex!(g, 2.0, 2.0, 0.0)  # 9

    add_interior!(g, 1, 2, 4, true)
    add_interior!(g, 4, 5, 2, true)
    add_interior!(g, 2, 3, 6, false)
    add_interior!(g, 2, 5, 6, false)
    add_interior!(g, 4, 5, 8, false)
    add_interior!(g, 4, 7, 8, true)
    add_interior!(g, 5, 6, 8, false)
    add_interior!(g, 6, 8, 9, false)

    add_meta_edge!(g, 1, 2, true)
    add_meta_edge!(g, 2, 3, true)
    add_meta_edge!(g, 3, 6, true)
    add_meta_edge!(g, 6, 9, true)
    add_meta_edge!(g, 9, 8, true)
    add_meta_edge!(g, 8, 7, true)
    add_meta_edge!(g, 7, 4, true)
    add_meta_edge!(g, 4, 1, true)
    add_meta_edge!(g, 4, 2, false)
    add_meta_edge!(g, 2, 6, false)
    add_meta_edge!(g, 4, 5, false)
    add_meta_edge!(g, 5, 6, false)
    add_meta_edge!(g, 4, 8, false)
    add_meta_edge!(g, 8, 6, false)
    add_meta_edge!(g, 2, 5, false)
    add_meta_edge!(g, 5, 8, false)

    return g

end
