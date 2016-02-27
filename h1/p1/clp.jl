# Question 1a

using JuMP
using Clp

# Solve the problem in question 1 using Clp solver
m = Model(solver = ClpSolver())

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

# Optimal
# x1 = 3.0
# x2 = 0.0
# x3 = 3.0
# Objective Value = 48.0

# The result from Clp gives integer values while ECOS and SCS do not