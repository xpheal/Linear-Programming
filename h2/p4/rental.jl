using JuMP

m = Model()

# Euclidean algorithm to calculate the distance
euclidean(x1,y1,x2,y2) = 1.3 * (sqrt(((x2 - x1) ^ 2) + ((y2 - y1) ^ 2)))

# The coordinates of the agency
agency_Coordinate = [
	0 0;
	20 20;
	18 10;
	30 12;
	35 0;
	33 25;
	5 27;
	5 10;
	11 0;
	2 15
]

# num = number of agencies
(num,n) = size(agency_Coordinate)

# Create a num x num array to store the distances between agencies
distances = fill(0,num,num)
distances = convert(Array{Float64,2}, distances)

# Calculate the distance between agencies and store them in a num x num array
for i in 1:num
	for j in 1:num
		# Distances[i,j] = distances between agencies i and j
		distances[i,j] = euclidean(agency_Coordinate[i,1],agency_Coordinate[i,2],agency_Coordinate[j,1], agency_Coordinate[j,2])
	end
end

# The input data
required_cars = [10;6;8;11;9;7;15;7;9;12]
cars_present = [8;13;4;8;12;2;14;11;15;7]

# Movements of cars between agencies
# Movements[i,j] = number of cars moving from agency i to agency j
@defVar(m, movements[1:num,1:num] >= 0)

# The original number of cars + number of cars going into the agency - number of cars going out of the agency
# has to be more than the required cars
@addConstraint(m, flow[i in 1:num], sum(movements[:,i]) + cars_present[i] - sum(movements[i,:]) >= required_cars[i])

# Calculate the cost by dot multiplying the distances matrix and movements matrix and then minimize it
@setObjective(m, Min, vecdot(movements, distances))
status = solve(m)

# Print out the result
println("Total Cost: ", getObjectiveValue(m) * 0.5)
# Print out the movement
println(convert(Array{Int64,2},getValue(movements)))
# Print out the amount of cars present after the day to compare with the required cars
for i in 1:num
	println("Required cars: ", required_cars[i], " Cars present after the day: ", cars_present[i] + getValue(sum(movements[:,i])) - getValue(sum(movements[i,:])))
end

# Results
# Total Cost: 152.63901632295628

# [0 0 0 0 0 0 0 0 0 0
#  0 0 1 0 0 5 1 0 0 0
#  0 0 0 0 0 0 0 0 0 0
#  0 0 0 0 0 0 0 0 0 0
#  0 0 0 3 0 0 0 0 0 0
#  0 0 0 0 0 0 0 0 0 0
#  0 0 0 0 0 0 0 0 0 0
#  0 0 0 0 0 0 0 0 0 5
#  2 0 3 0 0 0 0 1 0 0
#  0 0 0 0 0 0 0 0 0 0]

# Required cars: 10 Cars present after the day: 10.0
# Required cars: 6 Cars present after the day: 6.0
# Required cars: 8 Cars present after the day: 8.0
# Required cars: 11 Cars present after the day: 11.0
# Required cars: 9 Cars present after the day: 9.0
# Required cars: 7 Cars present after the day: 7.0
# Required cars: 15 Cars present after the day: 15.0
# Required cars: 7 Cars present after the day: 7.0
# Required cars: 9 Cars present after the day: 9.0
# Required cars: 12 Cars present after the day: 12.0

#=
	Explanation
	The cost for transporting the cars is $152.64.

	The movements of the car is as below:

	[i,j] means number of cars moving from agency i to agency j
	For example: there are 5 cars moving from agency 2 to agency 6
	Agency 6 has 2 cars and it require another 5 cars to fulfill the requirements
	
	i/j	1 2 3 4 5 6 7 8 9 10
	1	0 0 0 0 0 0 0 0 0 0
	2	0 0 1 0 0 5 1 0 0 0
	3	0 0 0 0 0 0 0 0 0 0
	4	0 0 0 0 0 0 0 0 0 0
	5	0 0 0 3 0 0 0 0 0 0
	6	0 0 0 0 0 0 0 0 0 0
	7	0 0 0 0 0 0 0 0 0 0
	8	0 0 0 0 0 0 0 0 0 5
	9	2 0 3 0 0 0 0 1 0 0
	10	0 0 0 0 0 0 0 0 0 0

	Further explanation is commented with the codes
=#