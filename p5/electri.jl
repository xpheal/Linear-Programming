# Question 5

using JuMP

m = Model()

# The original demand of the electricity
demand = [43, 40, 36, 36, 35, 38, 41, 46, 49, 48, 47, 47, 48, 46, 45, 47, 50, 63, 75, 75, 72, 66, 57, 50]

# Limit of the electricity purchased
limit = 65

# The cost when the electricity > 50 and <= 50
costLow = 100
costHigh = 400

# Capacity of the battery
capacity = 30

# Calculate the original cost
originalCost = 0

for i = 1:24
	if demand[i] <= 50
		originalCost += demand[i] * costLow
	else
		originalCost += (demand[i] - 50) * costHigh + 50 * costLow
	end
end

# @defVar(m, cost[1:24] >= 0)\

# The hourly usage of the battery has to be lower than the limit = 65
@defVar(m, 0 <= usage[1:24] <= limit)

# Variables used to calculate the cost 
@defVar(m, x[1:24] >= 0)
@defVar(m, y[1:24] <= 0)

# The amount of charge flowing into the battery, the amount of electricity purchased for the battery
@defVar(m, charge[1:24] <= 0)

# The amount of charge flowing out of the batter
@defVar(m, used[1:24] >= 0)

# The battery limited by capacity, if set to infinite capacity, just set b[1:25] >= 0
# For normal capacity 0 <= b[1:25] <= capacity
@defVar(m, b[1:25] >= 0)

# The battery is drained at the beginning
@addConstraint(m, b[1] == 0)

# The battery obtained in the next hour is equal to 
# battery this hour + the amount of electricity purchased for the battery - amount of electricity taken from the battery
@addConstraint(m, flow[i in 1:24], b[i] - charge[i] - used[i] == b[i + 1])

# The demand of the electricity is equal to
# the hourly usage of electricity + electricity purchased for battery - electricity given by the battery
@addConstraint(m, flow[i in 1:24], usage[i] + charge[i] + used[i] == demand[i])

# To calculate cost and minimize it
@addConstraint(m, flow[i in 1:24], x[i] + y[i] + 50 == usage[i])
@defExpr(totalCost, costHigh * sum(x) + costLow * (50 * 24 + sum(y)))
@setObjective(m, Min, totalCost)

status = solve(m)

# Print results
println("Electricity in battery: ")
println(convert(Array{Int64,1}, getValue(b)))
println("Electricity purchased for battery")
println(convert(Array{Int64,1}, getValue(charge)))
println("Electricity taken from battery")
println(convert(Array{Int64,1}, getValue(used)))
println("Electricity usage")
println(convert(Array{Int64,1}, getValue(usage)))
println("Cost = ", getObjectiveValue(m))
println("Original Cost = ", originalCost)
println("Savings = ", originalCost - getObjectiveValue(m))

# Results
# Electricity in battery for question a:
# [0,7,17,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,28,18,8,1,0,0,0]
# Electricity purchased for battery
# [-7,-10,-13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
# Electricity taken from battery
# [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,10,10,7,1,0,0]
# Electricity usage
# [50,50,49,36,35,38,41,46,49,48,47,47,48,46,45,47,50,61,65,65,65,65,57,50]
# Cost = 143400.0
# Original Cost = 152400
# Savings = 9000.0

# Electricity in battery for question b:
# [0,7,17,31,45,60,72,81,85,86,88,91,94,96,100,105,108,108,95,70,45,23,7,0,0]
# Electricity purchased for battery
# [-7,-10,-14,-14,-15,-12,-9,-4,-1,-2,-3,-3,-2,-4,-5,-3,0,0,0,0,0,0,0,0]
# Electricity taken from battery
# [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13,25,25,22,16,7,0]
# Electricity usage
# [50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50]
# Cost = 120000.0
# Original Cost = 152400
# Savings = 32400.0

#=	Explanation
	a) The amount of money save is 9000
	b) The amount of money save if battery has infinite capacity is 32400
	   and the capacity of the battery used is 108, maximum capacity used
	c) Gadfly won't install, printed out the arrays
=#









