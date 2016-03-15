using Gadfly
using JuMP

# Generate random points
points = 4 + randn(2,50)

m = Model()

(k,l) = size(points)

# center = (x[1],x[2]), radius = x[3]
@defVar(m, x[1:3] >= 0)

A = [1 0 0; 0 1 0; 0 0 0]
b = zeros(l, 3)
b[:,1] = points[1,:]
b[:,2] = points[2,:]
c = [0,0,1]

# Constraint so that all the points are in the circle
for i in 1:l
	@addConstraint(m, dot(c,x) >= norm((A*x) - (b[i,:]')))
end

# Minimize the radius
@setObjective(m, Min, dot(c,x))

status = solve(m)

# Obtain the values and plot the points and the circle
t = linspace(0,2pi,100)
x1 = getValue(x[1])
y1 = getValue(x[2])
r = getValue(x[3])
layer1 = layer(x = points[1,:], y = points[2,:], Geom.point, Theme(default_color=color("blue")))
layer2 = layer(x = r*cos(t) + x1, y = r*sin(t) + y1, Theme(default_color=color("green")), Geom.PolygonGeometry)
Graph1 = plot(layer1, layer2, Guide.title("Points in circle"), Guide.xlabel("x"), Guide.ylabel("y"), Coord.cartesian(fixed = true))

draw(PDF("Circle.pdf", 8inch, 8inch), Graph1)

