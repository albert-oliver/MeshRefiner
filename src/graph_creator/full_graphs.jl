"""
Quite complex 3d graph with `:value` property set for all normal vertices.
Some values are set to 0. Nice for testing draw functions.

```text
v---v---v---v---v
|\\  |  /|\\  |  /|
| \\ | / | \\ | / |
|  \\|/  |  \\|/  |
|   v---v---v---v
|  /|\\  |\\ /|\\  |
| / | \\ | v | \\ |
|/  |  \\|/ \\|  \\|
v---v---v---v---v
|\\  |  /|\\  |  /|
| \\ | / | \\ | / |
|  \\|/  |  \\|/  |
|   v   |   v   |
|  /|\\  |  / \\  |
| / | \\ | /   \\ |
|/  |  \\|/     \\|
v---v---v-------v
```
"""
function full_graph_1()
    g = FlatGraph()

    add_vertex!(g, [0.0, 8.0, 2.0])  # 1
    add_vertex!(g, [2.0, 8.0, 2.0])  # 2
    add_vertex!(g, [4.0, 8.0, 0.0])  # 3
    add_vertex!(g, [6.0, 8.0, 0.0])  # 4
    add_vertex!(g, [8.0, 8.0, 0.0])  # 5
    add_vertex!(g, [2.0, 6.0, 2.0])  # 6
    add_vertex!(g, [4.0, 6.0, 0.0])  # 7
    add_vertex!(g, [6.0, 6.0, 0.0])  # 8
    add_vertex!(g, [8.0, 6.0, 0.0])  # 9
    add_vertex!(g, [5.0, 5.0, 0.0])  # 10
    add_vertex!(g, [0.0, 4.0, 2.0])  # 11
    add_vertex!(g, [2.0, 4.0, 2.0])  # 12
    add_vertex!(g, [4.0, 4.0, 0.0])  # 13
    add_vertex!(g, [6.0, 4.0, 0.0])  # 14
    add_vertex!(g, [8.0, 4.0, 0.0])  # 15
    add_vertex!(g, [2.0, 2.0, 2.0])  # 16
    add_vertex!(g, [6.0, 2.0, 0.0])  # 17
    add_vertex!(g, [0.0, 0.0, 2.0])  # 18
    add_vertex!(g, [2.0, 0.0, 2.0])  # 19
    add_vertex!(g, [4.0, 0.0, 2.0])  # 20
    add_vertex!(g, [8.0, 0.0, 2.0])  # 21

    set_value!(g, 1, 0.0)
    set_value!(g, 2, 0.0)
    set_value!(g, 3, 1.5)
    set_value!(g, 4, 1.5)
    set_value!(g, 5, 2.5)
    set_value!(g, 6, 0.0)
    set_value!(g, 7, 1.5)
    set_value!(g, 8, 2.7)
    set_value!(g, 9, 2.5)
    set_value!(g, 10, 1.5)
    set_value!(g, 11, 0.0)
    set_value!(g, 12, 0.0)
    set_value!(g, 13, 1.5)
    set_value!(g, 14, 1.5)
    set_value!(g, 15, 1.5)
    set_value!(g, 16, 0.0)
    set_value!(g, 17, 1.5)
    set_value!(g, 18, 0.0)
    set_value!(g, 19, 0.0)
    set_value!(g, 20, 0.0)
    set_value!(g, 21, 0.0)

    add_interior!(g, 1, 2, 6)
    add_interior!(g, 2, 3, 6)
    add_interior!(g, 1, 6, 11)
    add_interior!(g, 11, 12, 6)
    add_interior!(g, 12, 13, 6)
    add_interior!(g, 3, 7, 6)
    add_interior!(g, 6, 7, 13)
    add_interior!(g, 7, 13, 10)
    add_interior!(g, 7, 8, 10)
    add_interior!(g, 8, 14, 10)
    add_interior!(g, 14, 13, 10)
    add_interior!(g, 3, 7, 8)
    add_interior!(g, 3, 4, 8)
    add_interior!(g, 4, 5, 8)
    add_interior!(g, 5, 8, 9)
    add_interior!(g, 8, 9, 15)
    add_interior!(g, 8, 14, 15)
    add_interior!(g, 11, 18, 16)
    add_interior!(g, 11, 12, 16)
    add_interior!(g, 12, 13, 16)
    add_interior!(g, 13, 20, 16)
    add_interior!(g, 19, 20, 16)
    add_interior!(g, 18, 19, 16)
    add_interior!(g, 13, 20, 17)
    add_interior!(g, 13, 14, 17)
    add_interior!(g, 14, 15, 17)
    add_interior!(g, 15, 21, 17)
    add_interior!(g, 20, 21, 17)

    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 3, 4; boundary=true)
    add_edge!(g, 4, 5; boundary=true)
    add_edge!(g, 5, 9; boundary=true)
    add_edge!(g, 9, 15; boundary=true)
    add_edge!(g, 15, 21; boundary=true)
    add_edge!(g, 21, 20; boundary=true)
    add_edge!(g, 20, 19; boundary=true)
    add_edge!(g, 19, 18; boundary=true)
    add_edge!(g, 18, 11; boundary=true)
    add_edge!(g, 11, 1; boundary=true)

    add_edge!(g, 2, 6)
    add_edge!(g, 1, 6)
    add_edge!(g, 3, 6)
    add_edge!(g, 11, 6)
    add_edge!(g, 12, 6)
    add_edge!(g, 13, 6)
    add_edge!(g, 7, 6)
    add_edge!(g, 3, 7)
    add_edge!(g, 13, 7)
    add_edge!(g, 3, 8)
    add_edge!(g, 4, 8)
    add_edge!(g, 5, 8)
    add_edge!(g, 9, 8)
    add_edge!(g, 15, 8)
    add_edge!(g, 14, 8)
    add_edge!(g, 10, 8)
    add_edge!(g, 7, 8)
    add_edge!(g, 7, 10)
    add_edge!(g, 13, 10)
    add_edge!(g, 14, 10)
    add_edge!(g, 11, 12)
    add_edge!(g, 12, 13)
    add_edge!(g, 13, 14)
    add_edge!(g, 14, 15)
    add_edge!(g, 11, 16)
    add_edge!(g, 12, 16)
    add_edge!(g, 13, 16)
    add_edge!(g, 20, 16)
    add_edge!(g, 19, 16)
    add_edge!(g, 18, 16)
    add_edge!(g, 13, 20)
    add_edge!(g, 13, 17)
    add_edge!(g, 14, 17)
    add_edge!(g, 15, 17)
    add_edge!(g, 21, 17)
    add_edge!(g, 20, 17)

    return g
end

"""
Matrix of values for each vertex over time for graph [`full_graph_1`](@ref).
Each row is one time step.
"""
function sim_values_1()
    [
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 2.7 2.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 2.8 2.6 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 2.9 2.7 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.0 2.8 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.1 2.9 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.2 3.0 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.3 3.1 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.4 3.2 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.5 3.3 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.6 3.4 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.0 0.0 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.2 0.2 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.4 0.4 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.6 0.6 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        0.8 0.8 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
        1.0 1.0 1.5 1.5 2.0 0.0 1.5 3.7 3.5 1.5 0.0 0.0 1.5 1.5 1.5 0.0 1.5 0.0 0.0 0.0 0.0;
    ]
end
