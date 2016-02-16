# Question 1b

using JuMP
using ECOS

# Solve the problem in question 1 using ECOS solver
m = Model(solver = ECOSSolver())

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
# x1 = 2.999999998571697 -> 3
# x2 = 8.223270011736391e-9 -> 0
# x3 = 3.0000000001977236 -> 3
# Objective Value = 47.999999986810174 -> 48

#=	Explanation
	The result obtain from ECOS is slightly different from the one obtain from Clp
	For x1, ECOS->x1 <= CLp->x1
	For x2, ECOS->x2 >= Clp->x2
	For x3, ECOS->x3 >= Clp->x3
	For Objective, ECOS->Objective <= Clp->Objective
	The difference between the results are very small and less than 1
=#
