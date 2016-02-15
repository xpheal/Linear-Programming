using JuMP

m = Model()

# Materials
capacity = 20000

# Methods variable
@defVar(m, method1 >= 0)
@defVar(m, method2 >= 0)

# Round 1
@defExpr(A1, 0.05method1 + 0.15method2)
@defExpr(B1, 0.15method1 + 0.20method2)
@defExpr(C1, 0.20method1 + 0.25method2)
@defExpr(D1, 0.30method1 + 0.20method2)
@defExpr(Deft1, 0.30method1 + 0.20method2)

# Refire
@defVar(m, RDeft1 >= 0)
@defVar(m, RD1 >= 0)
@defVar(m, RC1 >= 0)
@defVar(m, RB1 >= 0)
@addConstraint(m, RDeft1 <= Deft1)
@addConstraint(m, RD1 <= D1)
@addConstraint(m, RC1 <= C1)
@addConstraint(m, RB1 <= B1)
@defExpr(A2, 0.10RDeft1 + 0.20RD1 + 0.30RC1 + 0.50RB1)
@defExpr(B2, 0.20RDeft1 + 0.20RD1 + 0.30RC1 + 0.50RB1)
@defExpr(C2, 0.15RDeft1 + 0.30RD1 + 0.40RC1)
@defExpr(D2, 0.25RDeft1 + 0.30RD1)
@defExpr(Deft2, 0.30RDeft1)

@defExpr(refire, A2 + B2 + C2 + D2 + Deft2)

# Grade
@defExpr(gradeD, D1 - RD1 + D2)
@defExpr(gradeC, C1 - RC1 + C2)
@defExpr(gradeB, B1 - RB1 + B2)
@defExpr(gradeA, A1 + A2)
@defExpr(deft, Deft1 - RDeft1 + Deft2)

@addConstraint(m, gradeA >= 1000)
@addConstraint(m, gradeB >= 2000)
@addConstraint(m, gradeC >= 3000)
@addConstraint(m, gradeD >= 3000)

# Capacity of the furnace
@defExpr(total, method1 + method2 + refire)
@addConstraint(m, total <= capacity)

# Minimize the cost
@defExpr(cost, 50method1 + 70method2 + 25refire)
@setObjective(m, Min, cost)

status = solve(m)

println("Status = ", status)
println("Method1 = ", getValue(method1))
println("Method2 = ", getValue(method2))
println("Refire = ", getValue(refire))
println("deft = ", getValue(deft))
println("gradeA = ", getValue(gradeA))
println("gradeB = ", getValue(gradeB))
println("gradeC = ", getValue(gradeC))
println("gradeD = ", getValue(gradeD))
println("Min Cost = " , getObjectiveValue(m))
