using GLMakie

ρ = 30
u(x, y) = (x + (ℯ^(ρ*x)-1) / (1-ℯ^ρ))*(y + (ℯ^(ρ*y)-1) / (1-ℯ^ρ))
fun(x, y) = u(x/100, y/100) * 30 - 10
xs = LinRange(0, 100, 100)
ys = LinRange(0, 100, 100)
zs = [fun(x, y) for x in xs, y in ys]

surface(xs, ys, zs)

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
# vertices = [
#     0.0 0.0;
#     1.0 0.0;
#     1.0 1.0;
#     0.0 1.0;
# ]
#
# faces = [
#     1 2 3;
#     3 4 1;
# ]
# mesh!(vertices, faces, color=:red, shading=true)
# fig
