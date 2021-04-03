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


# xs = LinRange(0, 1, 100)
# ys = LinRange(0, 1, 100)
# fun(x,y) = x*(1-x-y)
# zs = [fun(x, y) for x in xs, y in ys]
#
# surface(xs, ys, zs)

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

# xs = LinRange(0, 10, 100)
# ys = LinRange(0, 15, 100)
# zs = [cos(x) * sin(y) for x in xs, y in ys]
#
# fig = surface(xs, ys, zs)
#
# xs = LinRange(10, 30, 150)
# ys = LinRange(0, 15, 100)
# zs = [cos(x) * sin(y) for x in xs, y in ys]
# surface!(xs, ys, zs)
#
vertices = [
    [0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0],
    [1.0, 1.0, 0.0],
    [0.0, 1.0, 0.5],
]

faces = [
    [1, 2, 3],
    [3, 4, 1],
]
scene = mesh(vertices, faces, color=:red, shading=true)
scene
