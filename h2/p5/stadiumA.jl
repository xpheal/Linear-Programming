using JuMP

numTasks = 18

# Duration for each tasks
durations = [2,16,9,8,10,6,2,2,9,5,3,2,1,7,4,3,9,1]

# Predecessors for each tasks
pred = [();1;2;2;3;(4,5);4;6;(4,6);4;6;9;7;2;(4,14);(8,11,14);12;17]

m = Model()

# Variable for starting time of each tasks
@defVar(m, timeStart[1:numTasks] >= 0)

# The starting time of each tasks can only begin after it's predecessor is complete
@addConstraint(m, link[i in 1:numTasks, j in pred[i]], timeStart[i] >= timeStart[j] + durations[j])

# The minimum time for the last task to complete
@setObjective(m, Min, timeStart[end] + durations[end])
status = solve(m)

# Print results
println("Earliest possible week to complete is: ", getObjectiveValue(m))
println("Task: StartTime")
for i in 1:numTasks
	println(i, ": ", convert(Int64,getValue(timeStart[i])))
end

# Results
# Earliest possible week to complete is: 64.0
# Task: StartTime
# 1: 0
# 2: 2
# 3: 18
# 4: 18
# 5: 27
# 6: 37
# 7: 26
# 8: 43
# 9: 43
# 10: 26
# 11: 43
# 12: 52
# 13: 28
# 14: 18
# 15: 26
# 16: 46
# 17: 54
# 18: 63

#=
	Explanation
	The earliest possible date of completion is 64 weeks.
	The problem is solved by using network flow model.
	Further explanation is commented with the codes.
=#