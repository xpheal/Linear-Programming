using Gadfly
using JuMP

# import data set
raw = readdlm("xy_data.csv",',');
(k,l) = size(raw)

# Get the x and y data
xCoord = raw[:,1]
yCoord = raw[:,2]

# Set up array A, y = Aa, y = yCoord, a = weight
order = 3
A = zeros(k,order+1)

for i in 1:k
	for j = 1:order
		A[i,j] = xCoord[i]^(order - j + 1)
	end
end

m = Model()

# Variable for weight
@defVar(m, a[1:order+1])

# Calculate the best fit
@setObjective(m, Min, sum((yCoord - A * a) .^ 2))

status = solve(m)

# Calculate the x and y coordinates for the polynomial fit
weight = getValue(a)
npts = 100
xfine = linspace(0,10,npts)
ffine = ones(npts,1)

for j = 1:order
	ffine = [ffine.*xfine ones(npts,1)]
end

yfine = ffine * weight

# Plot the result
layer1 = layer(x = xCoord, y = yCoord, Geom.point, Theme(default_color=color("red")))
layer2 = layer(x = xfine, y = yfine, Geom.line, Theme(default_color=color("blue")))

Graph = plot(layer1, layer2, Guide.title("Polynomial fit"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["points", "best fit"], ["red", "blue"]))
draw(PDF("4a.pdf", 8inch, 8inch), Graph)