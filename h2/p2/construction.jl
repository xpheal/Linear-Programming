using JuMP

# The duration for the projects
duration = 4

# The deadline for each project
proj1_Deadline = 3
proj2_Deadline = 4
proj3_Deadline = 2

# The amount of worker-months needed for each project
proj1_Worker_Months = 8
proj2_Worker_Months = 10
proj3_Worker_Months = 12

available_workers_per_month = 8
workers_limit_per_project = 6

m = Model()

# No more than 6 workers can work on a single project 
@defVar(m, 0 <= proj1[1:duration] <= workers_limit_per_project)
@defVar(m, 0 <= proj2[1:duration] <= workers_limit_per_project) 
@defVar(m, 0 <= proj3[1:duration] <= workers_limit_per_project)

# The amount of workers used in a particular month cannot be more than 8
@addConstraint(m, flow[i in 1:duration], proj1[i] + proj2[i] + proj3[i] <= available_workers_per_month)

# The amount of work done by a project before their deadline has to be more than the worker-months requirement
@addConstraint(m, sum(proj1[1:proj1_Deadline]) >= proj1_Worker_Months)
@addConstraint(m, sum(proj2[1:proj2_Deadline]) >= proj2_Worker_Months)
@addConstraint(m, sum(proj3[1:proj3_Deadline]) >= proj3_Worker_Months)

# Minimize the total worker-months, but not important as long as there is a solution
@setObjective(m, Min, sum(proj1) + sum(proj2) + sum(proj3))
status = solve(m)

# Print results
println("status: ", status)
println("Objective: ", getObjectiveValue(m))
println()
println("Projects/Month: ")
println("Project1: ", getValue(proj1))
println("Project2: ", getValue(proj2))
println("Project3: ", getValue(proj3))
println()
println("Worker-months: ")
println("Project1: ", getValue(sum(proj1)))
println("Project2: ", getValue(sum(proj2)))
println("Project3: ", getValue(sum(proj3)))

# Results
# status: Optimal
# Objective: 30.0

# Projects/Month: 
# Project1: [0.0,2.0,6.0,0.0]
# Project2: [2.0,0.0,2.0,6.0]
# Project3: [6.0,6.0,0.0,0.0]

# Worker-months: 
# Project1: 8.0
# Project2: 10.0
# Project3: 12.0

#=
	Explanation
	The status of the model is optimal which means all 3 projects are completed on time.
	
	Projects/Month: 
	Months:   [1.0,2.0,3.0,4.0]
	Project1: [0.0,2.0,6.0,0.0]
	Project2: [2.0,0.0,2.0,6.0]
	Project3: [6.0,6.0,0.0,0.0]

	The worker-months requirement is met.
	The arrays above shows that each projects meet their constraints.
=#
