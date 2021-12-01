"Save graph `g` as GraphML file."
function save_GraphML(g, filename)
    xdoc = prepare_XML(g)
    XML.save_file(xdoc, filename)
end

function prepare_XML(g::FlatGraph)
    xdoc = _prepare_XML(g)
    xroot = XML.root(xdoc)
    xgraph = xroot["graph"][1]
    xtype = XML.new_child(xroot, "type")
    XML.add_text(xtype, "FlatGraph")
    xdoc
end

function prepare_XML(g::SphereGraph)
    xdoc = _prepare_XML(g)
    xroot = XML.root(xdoc)
    xgraph = xroot["graph"][1]
    xtype = XML.new_child(xroot, "type")
    XML.add_text(xtype, "SphereGraph")
    xradius = XML.new_child(xroot, "radius")
    XML.add_text(xradius, string(g.radius))
    xdoc
end

function _prepare_XML(g::HyperGraph)
    xdoc = XML.XMLDocument()
    xroot = XML.create_root(xdoc, "graphml")
    XML.set_attribute(xroot, "xmlns", "http://graphml.graphdrawing.org/xmlns")
    XML.set_attribute(
        xroot,
        "xmlns:xsi",
        "http://www.w3.org/2001/XMLSchema-instance",
    )
    XML.set_attribute(
        xroot,
        " xsi:schemaLocation",
        "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd",
    )

    keys = [
        Dict("id" => "d0", "for" => "node", "attr.name" => "type", "attr.type" => "int")
        Dict("id" => "d1", "for" => "node", "attr.name" => "x", "attr.type" => "double")
        Dict("id" => "d2", "for" => "node", "attr.name" => "y", "attr.type" => "double")
        Dict("id" => "d3", "for" => "node", "attr.name" => "z", "attr.type" => "double")
        Dict("id" => "d4", "for" => "node", "attr.name" => "value", "attr.type" => "double")
        Dict("id" => "d5", "for" => "node", "attr.name" => "v1", "attr.type" => "string")
        Dict("id" => "d6", "for" => "node", "attr.name" => "v2", "attr.type" => "string")
        Dict("id" => "d7", "for" => "node", "attr.name" => "refine", "attr.type" => "boolean")
        Dict("id" => "d8", "for" => "edge", "attr.name" => "boundary", "attr.type" => "boolean")
    ]
    name_to_id = Dict(map(key -> (key["attr.name"], key["id"]), keys))
    for key in keys
        xkey = XML.new_child(xroot, "key")
        for (attr, value) in key
            XML.set_attribute(xkey, attr, value)
        end
    end

    xgraph = XML.new_child(xroot, "graph")
    XML.set_attribute(xgraph, "id", "G")
    XML.set_attribute(xgraph, "edgedefault", "undirected")

    for v in 1:nv(g)
        xv = XML.new_child(xgraph, "node")
        XML.set_attribute(xv, "id", v)
        xattr = XML.new_child(xv, "data")
        XML.set_attribute(xattr, "key", name_to_id["type"])
        XML.add_text(xattr, string(get_type(g, v)))
        if is_vertex(g, v) || is_hanging(g, v)
            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["x"])
            XML.add_text(xattr, string(xyz(g, v)[1]))

            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["y"])
            XML.add_text(xattr, string(xyz(g, v)[2]))

            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["z"])
            XML.add_text(xattr, string(xyz(g, v)[3]))

            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["value"])
            XML.add_text(xattr, string(get_value(g, v)))
        end
        if is_hanging(g, v)
            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["v1"])
            XML.add_text(xattr, string(MG.get_prop(g.graph, v, :v1)))

            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["v2"])
            XML.add_text(xattr, string(MG.get_prop(g.graph, v, :v2)))
        end
        if is_interior(g, v)
            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["refine"])
            XML.add_text(xattr, string(should_refine(g, v)))
        end
    end

    egde_id = 1
    for (v1, v2) in all_edges(g)
        xv = XML.new_child(xgraph, "edge")
        XML.set_attribute(xv, "id", egde_id)
        XML.set_attribute(xv, "source", v1)
        XML.set_attribute(xv, "target", v2)

        if is_ordinary_edge(g, v1, v2)
            xattr = XML.new_child(xv, "data")
            XML.set_attribute(xattr, "key", name_to_id["boundary"])
            XML.add_text(xattr, string(is_on_boundary(g, v1, v2)))
        end
        egde_id += 1
    end

    xdoc
end

"Create graph from GraphML file"
function load_GraphML(filename)
    xdoc = XML.parse_file(filename)
    xroot = XML.root(xdoc)
    g = nothing
    if xroot["type"][1] == "SphereGraph"
        radius = parse(Float64, xroot["radius"][1])
        g = SphereGraph(radius)
    else
        g = FlatGraph()
    end
    types = Dict("int" => Int64, "boolean" => Bool, "double" => Float64, "string" => String)
    keys = map(key -> (XML.attribute(key, "id"), key), xroot["key"])
    keys = Dict(keys)

    tmp_g = MG.MetaGraph()
    vertex_map = Dict()
    for v in xroot["graph"][1]["node"]
        MG.add_vertex!(tmp_g)
        v_id = MG.nv(tmp_g)
        vertex_map[XML.attribute(v, "id")] = v_id
        for data in v["data"]
            value = XML.content(data)
            key_id = XML.attribute(data, "key")
            key = keys[key_id]
            type = types[XML.attribute(key, "attr.type")]
            name = XML.attribute(key, "attr.name")
            MG.set_prop!(tmp_g, v_id, Symbol(name), parse(type, value))
        end
    end

    for e in xroot["graph"][1]["edge"]
        src = vertex_map[XML.attribute(e, "source")]
        dst = vertex_map[XML.attribute(e, "target")]
        MG.add_edge!(tmp_g, src, dst)
        for data in e["data"]
            value = XML.content(data)
            key_id = XML.attribute(data, "key")
            key = keys[key_id]
            type = types[XML.attribute(key, "attr.type")]
            name = XML.attribute(key, "attr.name")
            MG.set_prop!(tmp_g, src, dst, Symbol(name), parse(type, value))
        end
    end

    XML.free(xdoc)

    vertex_map_real = Dict()
    # Normal vertices
    for v in MG.filter_vertices(tmp_g, :type, VERTEX)
        x = MG.get_prop(tmp_g, v, :x)
        y = MG.get_prop(tmp_g, v, :y)
        z = MG.get_prop(tmp_g, v, :z)
        value = MG.get_prop(tmp_g, v, :value)
        add_vertex!(g, [x, y, z], value=value)
        vertex_map_real[v] = nv(g)
    end

    # Hanging nodes
    for v in MG.filter_vertices(tmp_g, :type, HANGING)
        x = MG.get_prop(tmp_g, v, :x)
        y = MG.get_prop(tmp_g, v, :y)
        z = MG.get_prop(tmp_g, v, :z)
        value = MG.get_prop(tmp_g, v, :value)
        v1 = vertex_map[MG.get_prop(tmp_g, v, :v1)]
        v1 = vertex_map_real[v1]
        v2 = vertex_map[MG.get_prop(tmp_g, v, :v2)]
        v2 = vertex_map_real[v2]
        add_hanging!(g, v1, v2, [x, y, z], value=value)
        vertex_map_real[v] = nv(g)
    end

    # Interiors
    for v in MG.filter_vertices(tmp_g, :type, INTERIOR)
        refine = MG.get_prop(tmp_g, v, :refine)
        v1, v2, v3 = map(x -> vertex_map_real[x], Gr.neighbors(tmp_g, v))
        add_interior!(g, v1, v2, v3, refine=refine)
        vertex_map_real[v] = nv(g)
    end

    for e in Gr.edges(tmp_g)
        if !isempty(MG.props(tmp_g, e))
            v1 = vertex_map_real[e.src]
            v2 = vertex_map_real[e.dst]
            boundary = MG.get_prop(tmp_g, e, :boundary)
            add_edge!(g, v1, v2, boundary=boundary)
        end
    end

    g
end

import Base.parse
parse(::Type{T}, s::AbstractString) where T<:AbstractString = string(s)
