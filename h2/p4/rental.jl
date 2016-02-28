using JuMP

m = Model()

euclidean(x1,y1,x2,y2) = sqrt(((x2 - x1) ^ 2) + ((y2 - y1) ^ 2))

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



distances = fill(0,num,num)
distances = convert(Array{Float64,2}, distances)

for i in 1:num
	for j in 1:num
		distances[i,j] = euclidean(agency_Coordinate[i,1],agency_Coordinate[i,2],agency_Coordinate[j,1], agency_Coordinate[j,2])
	end
end

required_cars = [10;6;8;11;9;7;15;7;9;12]
cars_present = [8;13;4;8;12;2;14;11;15;7]

@defVar(m, movements[1:num,1:num] >= 0)

# println(distances)

# @addConstraint(m, flow[i in 1:10, j in 1:10], movements[i,j] + cars_present[i] - movements[j,i] >= required_cars[i])
@addConstraint(m, flow[i in 1:num], sum(movements[:,i]) + cars_present[i] - sum(movements[i,:]) >= required_cars[i])

@setObjective(m, Min, vecdot(movements, distances))

status = solve(m)

println("Total Cost: ", getObjectiveValue(m) * 0.5)

println(getValue(movements))

println(distances)

println(required_cars)

for i in 1:num
	println(cars_present[i] + getValue(sum(movements[:,i])) - getValue(sum(movements[i,:])))
end