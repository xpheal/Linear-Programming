using Gadfly
using JuMP

# import data set
raw = readdlm("voltages.csv",',');

# Get the input
input = raw[:,1]
t = length(raw)

# A function that given the weight lbd, return (smoothed voltage, R(v), dist)
function solveVoltage(lbd)

	m = Model()

	# output = smoothed voltage
	@defVar(m, output[1:t])

	# dist is the difference between the original voltage and the smoothed voltage
	@defExpr(m, dist, output - input)

	# R(v) function
	@defExpr(m, rv, output[2:t] - output[1:t-1])

	# Minimize both R(v) and dist, lbd is used to control the tradeoff
	@setObjective(m, Min, dot(dist,dist) + lbd * dot(rv,rv))

	status = solve(m)

	retRv = norm(getValue(rv))
	retDist = norm(getValue(dist))
	retOutput = getValue(output)

	return(retOutput, retRv, retDist)
end

# A modified function so that lbd is multiplied with dist instead of R(v)
# When lbd is set to 0, allow us to put all the weight on R(v)
function solveVoltageOpposite(lbd)

	m = Model()

	# output = smoothed voltage
	@defVar(m, output[1:t])

	# dist is the difference between the original voltage and the smoothed voltage
	@defExpr(m, dist, output - input)

	# R(v) function
	@defExpr(m, rv, output[2:t] - output[1:t-1])

	# Minimize both R(v) and dist, lbd is used to control the tradeoff
	@setObjective(m, Min, dot(dist,dist) + lbd * dot(rv,rv))

	status = solve(m)

	retRv = norm(getValue(rv))
	retDist = norm(getValue(dist))
	retOutput = getValue(output)

	return(retOutput, retRv, retDist)
end


# lbd = 1 to test if it is more smoothed
(output1, rv1, dist1) = solveVoltage(1)

# lbd = 0, all the weight is placed on dist
(output2, rv2, dist2) = solveVoltage(0)

# lbd = infinity, all the weight is placed on R(v)
(output3, rv3, dist3) = solveVoltageOpposite(0)

# lbd = 5 to test if it is more smoothed
(output4, rv4, dist4) = solveVoltage(5)

# Tradeoff curve
TC = 30
rvTC = zeros(TC)
distTC = zeros(TC)
for (i,x) in enumerate(logspace(-5,1,TC))
    (out, rvTC[i],distTC[i]) = solveVoltage(x)
end;

tradeoffCurve = plot(x = rvTC, y = distTC, Geom.line, Guide.title("TradeoffCurve: dist against R(v)"), Guide.xlabel("R(v)"), Guide.ylabel("Dist"))

x_axis = collect(1:1:t)
layer1 = layer(x = x_axis, y = input, Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = x_axis, y = output1, Geom.line, Theme(default_color=color("blue")))
layer3 = layer(x = x_axis, y = output2, Geom.line, Theme(default_color=color("orange")))
layer4 = layer(x = x_axis, y = output3, Geom.line, Theme(default_color=color("green")))
layer5 = layer(x = x_axis, y = output4, Geom.line, Theme(default_color=color("brown")))
Graph1 = plot(layer1, layer2, Guide.title("Voltage against time (Smoothed Voltage"), Guide.xlabel("Time"), Guide.ylabel("Voltage"), Guide.manual_color_key("Legend", ["Original voltage", "Smoothed voltage"], ["red", "blue"]))
Graph2 = plot(layer1, layer3, Guide.title("Voltage against time (All weight on dist)"), Guide.xlabel("Time"), Guide.ylabel("Voltage"), Guide.manual_color_key("Legend", ["Original voltage", "Smoothed voltage"], ["red", "orange"]))
Graph3 = plot(layer1, layer4, Guide.title("Voltage against time (All weight on R(v))"), Guide.xlabel("Time"), Guide.ylabel("Voltage"), Guide.manual_color_key("Legend", ["Original voltage", "Smoothed voltage"], ["red", "green"]))
Graph4 = plot(layer1, layer5, Guide.title("Voltage against time (More Smoothed Voltage"), Guide.xlabel("Time"), Guide.ylabel("Voltage"), Guide.manual_color_key("Legend", ["Original voltage", "Smoothed voltage"], ["red", "brown"]))

draw(PDF("tradeoff.pdf", 8inch, 8inch), tradeoffCurve)
draw(PDF("graph1.pdf", 8inch, 8inch), Graph1)
draw(PDF("graph2.pdf", 8inch, 8inch), Graph2)
draw(PDF("graph3.pdf", 8inch, 8inch), Graph3)
draw(PDF("graph4.pdf", 8inch, 8inch), Graph4)

#=
	Explanation
	Voltage is smoothed and tradeoffs are calculated
	Weight is used to minimize either dist or R(v)
	
	Graph1: The graph with weight = 1
	Graph2: The graph with weight = 0, all weight on dist
	Graph3: The graph with weight = infinity, all weight on R(v), accomplished by modifying the code and move the weight to dist
	Graph4: A more smoothed voltage when compare to graph 1
	Graph5: Tradeoff between dist and R(v)

	More explanation is commented in code	
=#