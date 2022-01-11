"""
    simple_graph(dims = (1.0, 1.0))

Rectangle made of two triangles.

# Arguments
- `dims`: Dimensions of rectangle. Can be:
    - `(start_x, start_y, stop_x, stop_y)`
    - `(stop_x, stop_y)` - rectangle starts at `0`
    - `a::Real` - square with starting at `(0, 0)` with side length `a`

v---v
|\\  |
| \\ |
|  \\|
v---v
"""
function simple_graph(
    dims::Union{Real, Tuple{<:Real, <:Real}, Tuple{<:Real, <:Real, <:Real, <:Real}} = 1.0
    )
    if typeof(dims) <: Real
        dims = (dims, dims)
    end

    start_x = 0
    start_y = 0
    stop_x = 0
    stop_y = 0
    if length(dims) == 2
        stop_x = dims[1]
        stop_y = dims[2]
    else    # length(dims) == 4
        start_x = dims[1]
        start_y = dims[2]
        stop_x = dims[3]
        stop_y = dims[4]
    end

    g = FlatGraph()

    add_vertex!(g, [start_x, start_y, 0.0])  # 1
    add_vertex!(g, [stop_x, start_y, 0.0])    # 2
    add_vertex!(g, [start_x, stop_y, 0.0])   # 3
    add_vertex!(g, [stop_x, stop_y, 0.0])    # 4

    add_interior!(g, 1, 3, 4)
    add_interior!(g, 1, 2, 4)

    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 4, boundary=true)
    add_edge!(g, 3, 4, boundary=true)
    add_edge!(g, 1, 3, boundary=true)
    add_edge!(g, 1, 4)

    return g
end

"""
Retrun graph as below with interiors. Interior of top triangle is set to be
refinded.

```text
   v
  / \\
 v---v--v
 |  /|\\ |
 | / | v
 |/  |/
 v---v
```
"""
function example_graph_1()
    g = FlatGraph()

    # vertices
    add_vertex!(g, [2.0, 0.0, 0.0])  # 1
    add_vertex!(g, [0.0, 2.0, 0.0])  # 2
    add_vertex!(g, [0.0, 9.0, 0.0])  # 3
    add_vertex!(g, [4.5, 11.0, 0.0]) # 4
    add_vertex!(g, [8.5, 8.0, 0.0])  # 5
    add_vertex!(g, [9.0, 3.5, 0.0])  # 6
    add_vertex!(g, [4.5, 1.0, 0.0])  # 7

    # interiors
    add_interior!(g, 1, 2, 7; refine=true)
    add_interior!(g, 2, 3, 7)
    add_interior!(g, 3, 4, 7)
    add_interior!(g, 4, 5, 7)
    add_interior!(g, 5, 6, 7)

    #edges
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5)
    add_edge!(g, 5, 6)
    add_edge!(g, 6, 7)
    add_edge!(g, 7, 1)
    add_edge!(g, 7, 2)
    add_edge!(g, 7, 3)
    add_edge!(g, 7, 4)
    add_edge!(g, 7, 5)

    return g
end

"""
Return graph as below with interiors. Note hanging node on the right.

```text
v---------------v
|\\             /|
| \\           / |
|  \\         /  |
|   \\       /   |
|    \\     /    |
|     \\   /     |
|      \\ /      |
v-------v-------v
|\\     / \\     /|
| \\   /   \\   h |
|  \\ /     \\ / \\|
v---v-------v---v
|  / \\     / \\  |
| /   \\   /   \\ |
|/     \\ /     \\|
v-------v-------v
```
"""
function example_graph_2()
    g = FlatGraph()

    # vertices
    add_vertex!(g, [0.0, 0.0, 0.0])  # 1
    add_vertex!(g, [8.0, 0.0, 0.0])  # 2
    add_vertex!(g, [0.0, 4.0, 0.0])  # 3
    add_vertex!(g, [4.0, 4.0, 0.0])  # 4
    add_vertex!(g, [8.0, 4.0, 0.0])  # 5
    add_vertex!(g, [0.0, 6.0, 0.0])  # 6
    add_vertex!(g, [2.0, 6.0, 0.0])  # 7
    add_vertex!(g, [6.0, 6.0, 0.0])  # 8
    add_vertex!(g, [8.0, 6.0, 0.0])  # 9
    add_vertex!(g, [0.0, 8.0, 0.0])  # 10
    add_vertex!(g, [4.0, 8.0, 0.0])  # 11
    add_vertex!(g, [8.0, 8.0, 0.0])  # 12
    add_hanging!(g, 5, 8, [7.0, 5.0, 0.0])  # 13

    # interiors
    add_interior!(g, 1, 2, 4)
    add_interior!(g, 1, 3, 4)
    add_interior!(g, 2, 4, 5)
    add_interior!(g, 3, 6, 7)
    add_interior!(g, 3, 4, 7)
    add_interior!(g, 4, 7, 8)
    add_interior!(g, 4, 5, 8)
    add_interior!(g, 5, 9, 13)
    add_interior!(g, 8, 9, 13)
    add_interior!(g, 6, 7, 10)
    add_interior!(g, 7, 10, 11)
    add_interior!(g, 7, 8, 11)
    add_interior!(g, 8, 11, 12)
    add_interior!(g, 8, 9, 12)

    #edges
    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 5; boundary=true)
    add_edge!(g, 5, 9; boundary=true)
    add_edge!(g, 9, 12; boundary=true)
    add_edge!(g, 12, 11; boundary=true)
    add_edge!(g, 11, 10; boundary=true)
    add_edge!(g, 10, 6; boundary=true)
    add_edge!(g, 6, 3; boundary=true)
    add_edge!(g, 3, 1; boundary=true)
    add_edge!(g, 1, 4)
    add_edge!(g, 2, 4)
    add_edge!(g, 3, 4)
    add_edge!(g, 4, 5)
    add_edge!(g, 3, 7)
    add_edge!(g, 4, 7)
    add_edge!(g, 4, 8)
    add_edge!(g, 5, 13)
    add_edge!(g, 8, 13)
    add_edge!(g, 9, 13)
    add_edge!(g, 6, 7)
    add_edge!(g, 7, 8)
    add_edge!(g, 8, 9)
    add_edge!(g, 7, 10)
    add_edge!(g, 7, 11)
    add_edge!(g, 8, 11)
    add_edge!(g, 8, 12)

    return g
end

"""
Return graph as below with interiors.

```text
v---v---v
|  /|\\  |
| / | \\ |
|/  |  \\|
v---v---v
|\\  |  /|
| \\ | / |
|  \\|/  |
v---v---v
```
"""
function example_graph_3()
    g = FlatGraph()

    add_vertex!(g, [0.0, 0.0, 0.0])  # 1
    add_vertex!(g, [1.0, 0.0, 0.0])  # 2
    add_vertex!(g, [2.0, 0.0, 0.0])  # 3
    add_vertex!(g, [0.0, 1.0, 0.0])  # 4
    add_vertex!(g, [1.0, 1.0, 0.0])  # 5
    add_vertex!(g, [2.0, 1.0, 0.0])  # 6
    add_vertex!(g, [0.0, 2.0, 0.0])  # 7
    add_vertex!(g, [1.0, 2.0, 0.0])  # 8
    add_vertex!(g, [2.0, 2.0, 0.0])  # 9

    add_interior!(g, 1, 2, 4)
    add_interior!(g, 4, 5, 2)
    add_interior!(g, 2, 3, 6)
    add_interior!(g, 2, 5, 6)
    add_interior!(g, 4, 5, 8)
    add_interior!(g, 4, 7, 8)
    add_interior!(g, 5, 6, 8)
    add_interior!(g, 6, 8, 9)

    add_edge!(g, 1, 2; boundary=true)
    add_edge!(g, 2, 3; boundary=true)
    add_edge!(g, 3, 6; boundary=true)
    add_edge!(g, 6, 9; boundary=true)
    add_edge!(g, 9, 8; boundary=true)
    add_edge!(g, 8, 7; boundary=true)
    add_edge!(g, 7, 4; boundary=true)
    add_edge!(g, 4, 1; boundary=true)
    add_edge!(g, 4, 2)
    add_edge!(g, 2, 6)
    add_edge!(g, 4, 5)
    add_edge!(g, 5, 6)
    add_edge!(g, 4, 8)
    add_edge!(g, 8, 6)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 8)

    return g
end
