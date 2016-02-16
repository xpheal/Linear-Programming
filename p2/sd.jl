# Question 2

using JuMP

# The equality-constrained form of question 2

m = Model()

# z1 = u - v
# because z1 has no constraints, u - v, where u >= 0 and v >= 0, has no constrants
@defVar(m, u >= 0) 
@defVar(m, v >= 0)

# z2 = x - 1
@defVar(m, x >= 0)

# z3 = y - 1
@defVar(m, y >= 0)

# z4 = z - 2
@defVar(m, z >= 0)

# z2 <= 5, z3 <= 5, z4 <= 2
# (x - 1) + x1 == 5 is z2 <= 5
# (y - 1) + y1 == 5 is z3 <= 5
# (z - 2) + z2 == 2 is z4 <= 2
# Example: Transformation is obtained by converting z2 <= 5 -> (x - 1) <= 5
# Add in a variable x1 to transform (x - 1) <= 5 -> (x - 1) + x1 == 5
# Which is the equality-constrained form
@defVar(m, x1 >= 0)
@defVar(m, y1 >= 0)
@defVar(m, z1 >= 0)
@addConstraint(m, (x - 1) + x1 == 5)
@addConstraint(m, (y - 1) + y1 == 5)
@addConstraint(m, (z - 2) + z1 == 2)

# -z1 + 6z2 - z3 + z4 >= -3
# Uses -b, where b >= 0, because left hand side is larger than right hand side
@defVar(m, b >= 0)
@addConstraint(m, -(u - v) + 6(x - 1) - (y - 1) + (z - 2) - b == -3)

# 7z2 + 74 == 5
@addConstraint(m, 7(x - 1) + (z - 2) == 5)

# z3 + z4 <= 2
# Uses +a, where a <= 0, because left hand side is smaller than right handside
@defVar(m, a >= 0)
@addConstraint(m, (y - 1) + (z - 2) + a == 2)

# Objective = Minimize, -3z1 - z2
@setObjective(m, Min, -(3(u - v) - (x - 1)))
status = solve(m)

# Print out result
println(m)
println(status)
println("z1 = ", getValue(u - v))
println("z2 = ", getValue(x - 1))
println("z3 = ", getValue(y - 1))
println("z4 = ", getValue(z - 2))
println("Objective Value = ", -getObjectiveValue(m))

# Results
# Min -3 u + 3 v + x - 1
# Subject to
#  x + x1 == 6
#  y + y1 == 6
#  z + z1 == 4
#  -u + v + 6 x - y + z - b == 4
#  7 x + z == 14
#  y + z + a == 5
#  u >= 0
#  v >= 0
#  x >= 0
#  y >= 0
#  z >= 0
#  x1 >= 0
#  y1 >= 0
#  z1 >= 0
#  b >= 0
#  a >= 0

# Optimal
# z1 = 8.571428571428571
# z2 = 0.4285714285714286
# z3 = -1.0
# z4 = 2.0
# Objective Value = 25.28571428571429

#=	Explanation
	The result obtain through equality-constained form is the same as the original form
	Explanation on the transformation is commented before each line of code
=#
















