using JuMP

m = Model()

order = 500

# Materials
@defVar(m, 0 <= Ia1 <= 400)
@defVar(m, 0 <= Ia2 <= 300)
@defVar(m, 0 <= Ia3 <= 600)
@defVar(m, 0 <= C1 <= 500)
@defVar(m, 0 <= C2 <= 200)
@defVar(m, 0 <= A1 <= 300)
@defVar(m, 0 <= A2 <= 250)

# Calculations to obtain C Cu Mn
@defExpr(C, 2.5Ia1 + 3Ia2)
@defExpr(Cu, 0.3Ia3 + 90C1 + 96C2 + 0.4A1 + 0.6A2)
@defExpr(Mn, 1.3Ia1 + 0.8Ia2 + 4C2 + 1.2A1)
@defExpr(cost, 200Ia1 + 250Ia2 + 150Ia3 + 220C1 + 240C2 + 200A1 + 165A2)
@defExpr(weight, Ia1 + Ia2 + Ia3 + C1 + C2 + A1 + A2)

# Constraint for C Cu Mn grade
@addConstraint(m, 2*order <= C <= 3*order)
@addConstraint(m, 0.4*order <= Cu <= 0.6*order)
@addConstraint(m, 1.2*order <= Mn <= 1.65*order)

# Tons of steel = 500
@addConstraint(m, weight == order)

@setObjective(m, Min, cost)

status = solve(m)

println("Status = ", status)
println("Ia1 = ", getValue(Ia1)/order*100)
println("Ia2 = ", getValue(Ia2)/order*100)
println("Ia3 = ", getValue(Ia3)/order*100)
println("C1 = ", getValue(C1)/order*100)
println("C2 = ", getValue(C2)/order*100)
println("A1 = ", getValue(A1)/order*100)
println("A2 = ", getValue(A2)/order*100)
println("C = ", getValue(C))
println("Cu = ", getValue(Cu))
println("Mn = ", getValue(Mn))
println("Weight = ", getValue(weight))
println("Min Cost = " , getObjectiveValue(m))
