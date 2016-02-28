# Use duality
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
minNutrient = raw[2, n_nutrients][:]

# Size of the originalData
# m2 = number of rows, n2 = number of columns
(m2,n2) = size(originalData)

m = Model()

# Convert the arrays into float for matrix multiplication
originalData = convert(Array{Float64,2}, originalData)
minNutrient = convert(Array{Float64,1}, minNutrient)

# Array of costs for each type of nutrients
@defVar(m, nutrientsCost[1:n2] >= 0)

# The duality of the linear program

# The amount of nutrients in each of the food multiply by the cost of the nutrients must 
# not exceed the $1 worth of the food
@addConstraint(m, originalData * nutrientsCost .<= fill(1,77,1))

# Minimize the total cost of the nutrients
@setObjective(m, Max, dot(nutrientsCost, minNutrient))

status = solve(m)

# Print out results
println("Status: ", status)
println("(Optimal)Cheapest diet cost: ", getObjectiveValue(m) * 365)

println()
println("Worth of each type of nutrients")
println("Nutrients: Worth")
for k in 1:n2
	println(nutrients[k], ": ", getValue(nutrientsCost[k]))
end

println("Willingness to pay for 1g of calcium: ", getValue(nutrientsCost[3]))
println("Willingness to pay for 500mg of calcium: ", getValue(nutrientsCost[3])/2)

# Results obtained
# (Optimal)Cheapest diet cost: 39.661731545466274

# Worth of each type of nutrients
# Nutrients: Worth
# Calories (1000): 0.008765147298049485
# Protein (g): 0.0
# Calcium (g): 0.03173771344563715
# Iron (mg): 0.0
# Vitamin A (1000 IU): 0.00040023272172538176
# Thiamine (mg): 0.0
# Riboflavin (mg): 0.016358032699276687
# Niacin (mg): 0.0
# Ascorbic Acid (mg): 0.00014411751545899702
# Willingness to pay for 1g of calcium: 0.03173771344563715
# Willingness to pay for 500mg of calcium: 0.015868856722818576


#= 
	Explanation
	Duality is used to calcualte the price that I am willing to pay for 500mg of calcium.
	The shadow price of all the nutrients are calculated.

	The duality calculation is correct because the answer obtained is the same as the original linear program.
	$39.66

	The shadow price for the 1g of calcium is $0.0317377 
	The amount that I am willing to pay for 500mg of calcium is $0.0158689
	ANSWER: $0.0158689
=#

#=
	Duality explanation
	Original linear program:
	data = food x nutrients (9x77 matrix), The transpose of the raw data
	cost = (77x1 matrix), The amount of each type of food
	minNutrients = (9x1 matrix), The minimum nutrients requirement

	minimize: sum(cost) or dot(cost, fill(1,77,1))
	subject to: data * cost .>= minNutrients
	cost >= 0

	Convert to duality:
	dualData = data', nutrients x food (77x9 matrix), The format of the original data
	nutrientsCost = (9x1 matrix), The shadow price of the nutrients
	fill(1,77,1) = A vertical matrix of 1 to represent $1

	maximize: dot(nutrientsCost, minNutrients)
	subject to: dualData * nutrientsCost .<= fill(1,77,1)
	nutrientsCost >= 0
=#





