using JuMP
using Gadfly

numTasks = 18

# Duration for each tasks
durations = [2,16,9,8,10,6,2,2,9,5,3,2,1,7,4,3,9,1]

# Predecessors for each tasks
pred = [();1;2;2;3;(4,5);4;6;(4,6);4;6;9;7;2;(4,14);(8,11,14);12;17]

# Maximum reduction
reduc = [0,3,1,2,2,1,1,0,2,1,1,0,0,2,2,1,3,0]

# Cost of reduction
costReduc = [0,30,26,12,17,15,8,0,42,21,18,0,0,22,12,6,16,0]

# Obtain the minimum time for last task to complete without week reduction
m = Model()

# Variable for starting time of each tasks
@defVar(m, timeStart[1:numTasks] >= 0)

# The starting time of each tasks can only begin after it's predecessor is complete
@addConstraint(m, link[i in 1:numTasks, j in pred[i]], timeStart[i] >= timeStart[j] + durations[j])

# The minimum time for the last task to complete
@setObjective(m, Min, timeStart[end] + durations[end])
status = solve(m)

# The original optimize time for task to complete without reduction
week_Without_Reduction = getObjectiveValue(m)


# Plot trade-off curve of additional cost against number of weeks early we wish the staidum to be completed
weekEarly = 0 # To set how many weeks early you want the stadium to be completed, incremented by 1 in the while loop
weeks = [] # Array to store weeks for plotting
cost = [] # Array to store cost for plotting
# While loop to generate all possible solutions for plotting graph
while status != :Infeasible
	m = Model()

	# Variable for starting time of each tasks
	@defVar(m, timeStart[1:numTasks] >= 0)

	# Time reduced must not me more than maximum reduction
	@defVar(m, timeReduc[1:numTasks] >= 0)
	@addConstraint(m, flow[i in 1:numTasks], timeReduc[i] <= reduc[i])

	# The starting time of each tasks can only begin after it's predecessor is complete
	@addConstraint(m, link[i in 1:numTasks, j in pred[i]], timeStart[i] >= timeStart[j] + durations[j] - timeReduc[j])

	# The time to complete the last task must be more than the optimize time minus the weekEarly variable
	# We can use the weekEarly variable to control the amount of week early we want the stadium to complete
	@addConstraint(m, timeStart[end] + durations[end] == week_Without_Reduction - weekEarly)

	# Minimize the cost of week reduction
	@setObjective(m, Min, dot(timeReduc, costReduc))
	status = solve(m)

	if status != :Infeasible
		# Store the results
		push!(weeks, weekEarly)
		push!(cost, getObjectiveValue(m))
		weekEarly += 1
	end
end

# Print out results to check for correctness
println(weeks')
println(cost')

# Plot the result
plotResult = plot(
	x = weeks, 
	y = cost,
	Guide.title("Time saved(weeks) against Additional Cost(\$1k)"),
	Guide.xlabel("Time saved(weeks)"),
	Guide.ylabel("Additional Cost(\$1k)"),
	Geom.line,
	Geom.point
)

# Save result to pdf
draw(PDF("result.pdf",8inch,8inch), plotResult)

# Results that are plotted
# Weeks: [0	1  2  3  4  5  6  7   8   9   10  11  12 ]
# Cost:  [0	15 31 47 63 80 97 123 153 183 213 255 297]


#=	
	Explanation
	1) Obtained the optimum completion time without any week reduction
	2) Decrement the optimum completion time by 1 until no solution is feasible
	3) For every decrement, calculate the cost
	4) Store the time reduced and cost in an array, then plot the graph
	Further explanation is commented with the codes
=#