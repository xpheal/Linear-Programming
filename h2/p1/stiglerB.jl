# Gluten free and vegan: the information of whether a food is gluten free and vegan is obtained through piazza
using JuMP

# import Stigler's data set
raw = readdlm("stigler.csv",',');
(m,n) = size(raw)

n_nutrients = 2:n      # columns containing nutrients
n_foods = 3:m          # rows containing food names

nutrients = raw[1,n_nutrients][:]   # the list of nutrients
foods = [raw[7:10,1]; raw[43:end,1]][:]     # the list of foods(only gluten free and vegan)

# Base nutrients from csv file (only gluten free and vegan)
originalData = [raw[7:10,n_nutrients]; raw[43:end,n_nutrients]]

# Minimum Nutrients Requirement
minNutrient = raw[2, n_nutrients]

# Size of the originalData
# m2 = number of rows, n2 = number of columns
(m2,n2) = size(originalData)

m = Model()

# Array of costs for each type of food
@defVar(m, cost[1:m2] >= 0)

# Data after multiplying by cost
@defVar(m, optimizeData[1:m2,1:n2] >= 0)

# Calculate the optimize nutrients provided by a food by multiplying the "base nutrients" by the optimize cost
@addConstraint(m, flow[i in 1:m2, j in 1:n2], optimizeData[i, j] == originalData[i, j] * cost[i])

# The total amount of nutrients obtained by the optimized data has to be more than the minimum requirement
@addConstraint(m, flow[i in 1:n2], sum(optimizeData[1:m2,i]) >= minNutrient[i])

# Minimize the total cost
@setObjective(m, Min, sum(cost))
stiglerCost = 39.93

status = solve(m)

# Print out results
println("Status: ", status)
println("(Optimal)Cheapest diet cost: ", getObjectiveValue(m) * 365)

println()
println("Optimal diet")
println("Foods: Amount")
for k in 1:m2
	if getValue(cost[k]) != 0
		println(foods[k], ": ", getValue(cost[k]))
	end
end

# Results obtained
# Status: Optimal
# (Optimal)Cheapest diet cost: 45.58854783427841

# Optimal diet
# Foods: Amount
# Corn Meal: 0.005344246335991779
# Cabbage: 0.011313245088275928
# Spinach: 0.005175748501287311
# Navy Beans, Dried: 0.10306689112726254

#= 
	Explanation
	The cheapest vegan and gluten-free diet cost $45.59 annually.

	The optimal diet is composed of
	Corn Meal: 0.005
	Cabbage: 0.011
	Spinach: 0.005
	Navy Beans, Dried: 0.103

	More accurate results can be obtained in the comments above
	Further explanation is commented with the codes
=#