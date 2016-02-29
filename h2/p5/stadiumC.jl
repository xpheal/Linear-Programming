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


# Plot trade-off curve of cost against number of weeks early we wish the staidum to be completed
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
# @addConstraint(m, timeStart[end] + durations[end] == )

# Minimize the cost of week reduction
@setObjective(m, Max, 30(week_Without_Reduction - timeStart[end] - durations[end]) - dot(timeReduc, costReduc))
status = solve(m)

println(getObjectiveValue(m))
println(getValue(timeStart[end] + durations[end]))
println(getValue(timeReduc'))
