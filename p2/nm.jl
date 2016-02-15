using JuMP

m = Model()

@defVar(m, z1)
@defVar(m, -1 <= z2 <= 5)
@defVar(m, -1 <= z3 <= 5)
@defVar(m, -2 <= z4 <= 2)

@addConstraint(m, -z1 + 6z2 - z3 + z4 >= -3)
@addConstraint(m, 7z2 + z4 == 5)
@addConstraint(m, z3 + z4 <= 2)

@setObjective(m, Max, 3z1 - z2)

status = solve(m)

println(m)
println(status)
println("z1 = ", getValue(z1))
println("z2 = ", getValue(z2))
println("z3 = ", getValue(z3))
println("z4 = ", getValue(z4))
println("Objective Value = ", getObjectiveValue(m))