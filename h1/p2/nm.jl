# Question 2

using JuMP

# The original LP form for question 2

m = Model()

# Variables
@defVar(m, z1)
@defVar(m, -1 <= z2 <= 5)
@defVar(m, -1 <= z3 <= 5)
@defVar(m, -2 <= z4 <= 2)

# Constraints
@addConstraint(m, -z1 + 6z2 - z3 + z4 >= -3)
@addConstraint(m, 7z2 + z4 == 5)
@addConstraint(m, z3 + z4 <= 2)

# Objective
@setObjective(m, Max, 3z1 - z2)
status = solve(m)

# Print results
println(status)
println("z1 = ", getValue(z1))
println("z2 = ", getValue(z2))
println("z3 = ", getValue(z3))
println("z4 = ", getValue(z4))
println("Objective Value = ", getObjectiveValue(m))

# Results
# Optimal
# z1 = 8.571428571428571
# z2 = 0.42857142857142855
# z3 = -1.0
# z4 = 2.0
# Objective Value = 25.28571428571429