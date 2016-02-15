using JuMP

m = Model()

# z1 = u - v
@defVar(m, u >= 0) 
@defVar(m, v >= 0)

# z2 = x - 1
@defVar(m, x >= 0)

# z3 = y - 1
@defVar(m, y >= 0)

# z4 = z - 2
@defVar(m, z >= 0)

# z2 <= 5, z3 <= 5, z4 <= 2
@addConstraint(m, (x - 1) <= 5)
@addConstraint(m, (y - 1) <= 5)
@addConstraint(m, (z - 2) <= 2)

# -z1 + 6z2 - z3 + z4 >= -3
@defVar(m, b >= 0)
@addConstraint(m, -(u - v) + 6(x - 1) - (y - 1) + (z - 2) - b == -3)

# 7z2 + 74 == 5
@addConstraint(m, 7(x - 1) + (z - 2) == 5)

# z3 + z4 <= 2
@defVar(m, a >= 0)
@addConstraint(m, (y - 1) + (z - 2) + a == 2)

@setObjective(m, Min, -(3(u - v) - (x - 1)))

status = solve(m)

println(m)
println(status)
println("z1 = ", getValue(u - v))
println("z2 = ", getValue(x - 1))
println("z3 = ", getValue(y - 1))
println("z4 = ", getValue(z - 1))
println("Objective Value = ", -getObjectiveValue(m))