# Question 4

using JuMP

m = Model()

# The capacity of the furnace
capacity = 20000

# Amount of germanium used in method 1 and 2
@defVar(m, method1 >= 0)
@defVar(m, method2 >= 0)

# Round 1
# The amount of germanium obtained according to grade, Deft = Defective
# For example, the amount of gradeA obtained is 5% of method1 and 15% of method2
@defExpr(A1, 0.05method1 + 0.15method2)
@defExpr(B1, 0.15method1 + 0.20method2)
@defExpr(C1, 0.20method1 + 0.25method2)
@defExpr(D1, 0.30method1 + 0.20method2)
@defExpr(Deft1, 0.30method1 + 0.20method2)

# Refire once
# The amount of germanium used in refiring have to be >= 0
@defVar(m, RDeft1 >= 0)
@defVar(m, RD1 >= 0)
@defVar(m, RC1 >= 0)
@defVar(m, RB1 >= 0)

# The amount of germanium used in refiring have to me lesser than the amount obtain in round 1
@addConstraint(m, RDeft1 <= Deft1)
@addConstraint(m, RD1 <= D1)
@addConstraint(m, RC1 <= C1)
@addConstraint(m, RB1 <= B1)

# The amount of germanium obtained according to grade after refiring
# For example, the amount of gradeD after refiring would be the 25% of defective and 30% of gradeD from round 1
@defExpr(A2, 0.10RDeft1 + 0.20RD1 + 0.30RC1 + 0.50RB1)
@defExpr(B2, 0.20RDeft1 + 0.20RD1 + 0.30RC1 + 0.50RB1)
@defExpr(C2, 0.15RDeft1 + 0.30RD1 + 0.40RC1)
@defExpr(D2, 0.25RDeft1 + 0.30RD1)
@defExpr(Deft2, 0.30RDeft1)

# The amount of germanium refired
@defExpr(refire, A2 + B2 + C2 + D2 + Deft2)

# The amount of germanium according to grade after round 1 and refiring
# it equals to the amount obtained in round 1 - the amount used in refiring + the amount obtained through refiring
@defExpr(gradeD, D1 - RD1 + D2)
@defExpr(gradeC, C1 - RC1 + C2)
@defExpr(gradeB, B1 - RB1 + B2)
@defExpr(gradeA, A1 + A2)
@defExpr(deft, Deft1 - RDeft1 + Deft2)

# The amount of germanium according to grade requested
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

# Print results
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

# Results
# Status = Optimal
# Method1 = 10563.38028169014
# Method2 = 0.0
# Refire = 4542.25352112676
# deft = 950.704225352113
# gradeA = 1119.718309859155
# gradeB = 2492.957746478873
# gradeC = 2999.9999999999995
# gradeD = 3000.0
# ****Min Cost = 641725.352112676****

#=	Explanation
	The minimum cost obtained is 641725.35
	Explanation is commented before lines of code
	In the results, gradeA, gradeB, gradeC and gradeD is the amount of transistors created
	Method1, Method2 and Refire is the amount of germanium melted
=#









