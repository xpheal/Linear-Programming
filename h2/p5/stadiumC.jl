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


# Calculate the maximum profit that the builder could make
m = Model()

# Variable for starting time of each tasks
@defVar(m, timeStart[1:numTasks] >= 0)

# Time reduced must not me more than maximum reduction
@defVar(m, timeReduc[1:numTasks] >= 0)
@addConstraint(m, flow[i in 1:numTasks], timeReduc[i] <= reduc[i])

# The starting time of each tasks can only begin after it's predecessor is complete
@addConstraint(m, link[i in 1:numTasks, j in pred[i]], timeStart[i] >= timeStart[j] + durations[j] - timeReduc[j])

# The bonus for every extra week the project finishes early
@defExpr(m, bonus, 30 * (week_Without_Reduction - timeStart[end] - durations[end]))
# Cost of the project
@defExpr(m, cost, dot(timeReduc, costReduc))
# Maximize the profit
@setObjective(m, Max, bonus - cost)
status = solve(m)

# Print results
println("Optimal Profit: ", getObjectiveValue(m))
println("Time project is completed: ", getValue(timeStart[end] + durations[end]))
println("Time saved: ", getValue(week_Without_Reduction - timeStart[end] - durations[end]))
println("Time reduction: ", getValue(timeReduc'))

# Results
# Optimal Profit: 87.0
# Time project is completed: 57.0
# Time saved: 7.0
# Time reduction: [0.0 0.0 1.0 0.0 2.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 3.0 0.0]

#=
	Explanation
	The time for project completion to maximize profit is 57 weeks.
	The time saved is 7 weeks.
	Profit is $87k.

	1) Calculate the optimal completion time without week reduction
	2) Bonus = 30 * (original optimal time - current optimal time)
	3) Maximize the profit

	Further explanation is commented with the code
=#
