using JuMP
using SCS

m = Model(solver = SCSSolver())
@defVar(m, 0 <= x1 <= 3)
@defVar(m, 0 <= x2 <= 3)
@defVar(m, 0 <= x3 <= 3)
@addConstraint(m, 2x1 >= x2 + x3)
@setObjective(m, Max, 5x1 - x2 + 11x3)
status = solve(m)

println(status)
println("x1 = ", getValue(x1))
println("x2 = ", getValue(x2))
println("x3 = ", getValue(x3))
println("Objective Value = ", getObjectiveValue(m))