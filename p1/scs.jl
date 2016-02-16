# Question 1c

using JuMP
using SCS

# Solve the problem in question 1 using SCS solver
m = Model(solver = SCSSolver())

# Variables
@defVar(m, 0 <= x1 <= 3)
@defVar(m, 0 <= x2 <= 3)
@defVar(m, 0 <= x3 <= 3)

# Constraints
@addConstraint(m, 2x1 >= x2 + x3)

# Objective
@setObjective(m, Max, 5x1 - x2 + 11x3)
status = solve(m)

# Print Results
println(status)
println("x1 = ", getValue(x1))
println("x2 = ", getValue(x2))
println("x3 = ", getValue(x3))
println("Objective Value = ", getObjectiveValue(m))

# Results
# Optimal
# x1 = 2.999985652990818 -> 3
# x2 = 4.149724928776938e-6 -> 0
# x3 = 3.0000130627112176 -> 3
# Objective Value = 48.00006780505256 -> 48

#=	Explanation
	The result obtain from ECOS is slightly different from the one obtain from Clp
	For x1, SCS->x1 <= CLp->x1
	For x2, SCS->x2 >= Clp->x2
	For x3, SCS->x3 >= Clp->x3
	For Objective, SCS->Objective >= Clp->Objective
	The difference between the results are very small and less than 1
	The difference between SCS and ECOS is that SCS->Objective >= ECOS->Objective
=#