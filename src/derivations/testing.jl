using GLMakie

# ρ = 100
# u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
# fun(x, y) = u(x/100, y/100) * 30 - 10
# r(x, y) = ((x-0.5)^2+(y-0.5)^2)^0.5
# f(x, y) = cos(2*π*r(x, y)) if r(x, y) > 1 else 0
# xs = LinRange(0, 1, 100)
# ys = LinRange(0, 1, 100)
# zs = [f(x, y) for x in xs, y in ys]
#
# s = surface(xs, ys, zs)


# using Plots; gr()
# ρ = 100
# u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
# fun(x, y) = u(x, y) + 1
# xs = LinRange(0, 1, 100)
# ys = LinRange(0, 1, 100)
# zs = [u(x, y) for x in xs, y in ys]
# Plots.plot(xs,ys,u,st=:surface)


xs = LinRange(0, 1, 100)
ys = LinRange(0, 1, 100)
f = Derivations.GraphCreator.block_fun([0.5, 0.25], [0.25, 0.5], 1.0)
zs = [f(x, y) for x in xs, y in ys]

fig = surface(xs, ys, zs)

# using Plots
# a = 0.5
# b = 2.5
# h = 2
# k = 0.5
# function f(x)
#     if x > 0
#         h - (h/b) * x
#     else
#         h + (h/a) * x
#     end
# end
# plot(f, -a, b)
#
# function factory(val)
#     u(x) = x+2
#     f(x) = val * u(x)
#     return f
# end

# x=range(-2,stop=2,length=100)
# y=range(sqrt(2),stop=2,length=100)
# f(x,y) = x*y-x-y+1
# plot(x,y,f)
#
# poly(
#     Point3f0[(0, 0, 0), (2, 0, 0), (3, 1, 1)],
#     color="#00FF00F0"
# )

xs = LinRange(0, 1, 100)
ys = LinRange(0, 1, 100)
function hat_fun(x, y; center=(0.5, 0.5))
    xp = center[1]
    yp = center[2]
    r=((x-xp)^2+(y-yp)^2)^0.5
    f(r) = r < 0.25 ? cos(2*π*r) : 0.0
    f(r)
end
zs = [hat_fun(x, y; center=(0.5, 0.5)) for x in xs, y in ys]
surface(xs, ys, zs)

# xs = LinRange(10, 30, 150)
# ys = LinRange(0, 15, 100)
# zs = [cos(x) * sin(y) for x in xs, y in ys]
# surface!(xs, ys, zs)
#
vertices = [
    0.0 0.0 0.0;
    1.0 0.0 0.0;
    1.0 1.0 0.0;
    0.0 1.0 1.0;
]

vertices2 = [
    0.0 0.0 1.0;
    1.0 0.0 1.0;
    1.0 1.0 1.0;
    0.0 1.0 2.0;
]

faces = [
    1 2 3;
    3 4 1;
]

faces2 = [
    1 2 3;
    3 4 1;
]

iter = [(vertices, faces), (vertices2, faces2)]

fig, ax, sth = mesh(vertices, faces, color=:red, shading=true)
# mesh!(vertices2, faces2, color=:lightblue, shading=true, transparency=true)

# animation settings
n_frames = 2
framerate = 1

record(fig, "color_animation.mp4", iter; framerate = framerate) do thing
    v,f = thing
    sth[1] = v
    sth[2] = f
end


function abc(iters)
    x = zeros(iters)
    for i in 1:iters
        x[i] = i*2+1-20
    end
end

function def(iters)
    x = zeros(iters)
    Threads.@threads for i in 1:iters
        x[i] = i*2+1-20
    end
end
