using JuMP

# import Stigler's data set
raw = readdlm("stigler.csv",',');
(m,n) = size(raw)

n_nutrients = 2:n      # columns containing nutrients
n_foods = 3:m          # rows containing food names

nutrients = raw[1,n_nutrients][:]   # the list of nutrients
foods = raw[n_foods,1][:]           # the list of foods

# Base nutrients from csv file
originalData = raw[n_foods, n_nutrients]

# Minimum Nutrients Requirement
minNutrient = raw[2, n_nutrients]

# Size of the originalData
# m2 = number of rows, n2 = number of columns
(m2,n2) = size(originalData)

m = Model()

# Another way of writing the linear program
# @addConstraint(m, optimizeData' * cost .>= minNutrient)
# @setObjective(m, Min, dot(cost, fill(1,m2,1)))

# This method is easier to understand
# Array of costs for each type of food
@defVar(m, cost[1:m2] >= 0)

# Data after multiplying by cost
@defVar(m, optimizeData[1:m2,1:n2] >= 0)

# Calculate the optimize nutrients provided by a food by multiplying the "base nutrients" by the optimize cost
@addConstraint(m, flow[i in 1:m2, j in 1:n2], optimizeData[i, j] == originalData[i, j] * cost[i])

# The total amount of nutrients obtained by the optimized data has to be more than the minimum requirement
@addConstraint(m, flow[i in 1:n2], sum(optimizeData[1:m2,i]) >= minNutrient[i])

# Calculate the total cost
@defExpr(totalCost, sum(cost))

# Minimize the total cost
@setObjective(m, Min, totalCost)
stiglerCost = 39.93

status = solve(m)

# Print out results
println("Status: ", status)
println("(Optimal)Cheapest diet cost: ", getObjectiveValue(m) * 365)
println("Stigler's diet cost: ", stiglerCost)
println("The difference is: ", stiglerCost - getObjectiveValue(m) * 365)

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
# (Optimal)Cheapest diet cost: 39.661731545466246
# Stigler's diet cost: 39.93
# The difference is: 0.2682684545337537

# Optimal diet
# Foods: Amount
# Wheat Flour (Enriched): 0.029519061676488267
# Liver (Beef): 0.0018925572907052635
# Cabbage: 0.011214435246144867
# Spinach: 0.005007660466725206
# Navy Beans, Dried: 0.06102856352669324

#= 
	Explanation
	The cheapest diet cost $39.66 annually.
	Stigler's annual cost is $39.93.
	The solution that I obtained is cheaper than Stigler's by $0.27

	The optimal diet is composed of
	Wheat Flour: 0.0295
	Liver: 0.002
	Cabbage: 0.011
	Spinach: 0.005
	Navy Beans, Dried: 0.061

	More accurate results can be obtained in the comments above
=#