using Gadfly
using JuMP

# import data set
raw = readdlm("xy_data.csv",',');
(k,l) = size(raw)

# Get the x and y data
xCoord = raw[:,1]
yCoord = raw[:,2]

# Set up array A, y = Aa, y = yCoord, a = weight
order = 2
A = zeros(k,(order+1)*2)

# Use if to generate A for spline fit
for i in 1:k
	for j = 1:order
		if xCoord[i] < 4
			A[i,j] = xCoord[i]^(order - j + 1)
		else
			A[i,j+3] = xCoord[i]^(order - j + 1)
		end
	end
end

m = Model()

# Variable for weight
@defVar(m, pq[1:(order+1)*2])

# Calculate the best fit
@setObjective(m, Min, sum((yCoord - A * pq) .^ 2))

status = solve(m)

# Calculate the x and y coordinates for the polynomial fit
weight = getValue(pq)
p = weight[1:3]
q = weight[4:6]

npts = 100
xfine = linspace(0,10,npts)
ffine = ones(npts,1)

for j = 1:order
	ffine = [ffine.*xfine ones(npts,1)]
end

# Plot the result
yfine = zeros(npts)
for i in 1:npts
	if xfine[i] < 4
		temp = ffine[i,:] * p
		yfine[i] = temp[1]
	else
		temp = ffine[i,:] * q
		yfine[i] = temp[1]
	end
end

# Plot the result
layer1 = layer(x = xCoord, y = yCoord, Geom.point, Theme(default_color=color("red")))
layer2 = layer(x = xfine, y = yfine, Geom.line, Theme(default_color=color("blue")))

# Draw the graph
Graph = plot(layer1, layer2, Guide.title("Spline fit"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["points", "best fit"], ["red", "blue"]))
draw(PDF("4b.pdf", 8inch, 8inch), Graph)

#=
	Explanation
	More explanation commented in code
	Basically this program takes in points and generate a spline fit graph
	Both quadratic pieces have same value and slope at x = 4, can be seen in graph
=#