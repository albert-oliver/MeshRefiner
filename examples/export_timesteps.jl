# assuming g and s are in context

using Dates

import MeshGraphs

T_START = 10
T_END = 100
DT = 10
OUTPUT_DIR = "output/objs"
LAND_FILENAME = "land.obj"
WATER_FILENAME = "water.obj"
Z_SCALE = 100

function join_filename(filename, sufix)
    base, ext = MeshRefiner.ProjectIO.split_filename(filename)
    return join([base, sufix, ".", ext])
end

function join_dir(dir, filename)
    return join([dir, "/", filename])
end

dir = string(now())
dir = replace(dir, Pair(":", "-"))
dir = replace(dir, Pair(".", "-"))
land_output = join_dir(OUTPUT_DIR, dir)
mkdir(land_output)
water_output = join_dir(land_output, "water")
mkdir(water_output)

land_filename = join_dir(land_output, LAND_FILENAME)
water_filename = join_dir(water_output, WATER_FILENAME)
MeshRefiner.ProjectIO.export_obj(g, land_filename; z_scale=Z_SCALE, function_ϵ=1e-5)

t_end = isnothing(T_END) ? size(s, 1) : T_END
for t in T_START:DT:t_end
    MeshGraphs.set_all_values!(g, s[t, :])
    filename = join_filename(water_filename, lpad(t,4,"0"))
    MeshRefiner.ProjectIO.export_obj(g, filename; include_terrain=false, include_fun=true, z_scale=Z_SCALE, function_ϵ=1e-5)
end
