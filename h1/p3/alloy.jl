# Question 3

using JuMP

m = Model()

# Amount for the order
order = 500

# Materials
# Constraint by availability of the materials
# Ia = Iron Alloy, C = Copper, A = Aluminium
@defVar(m, 0 <= Ia1 <= 400)
@defVar(m, 0 <= Ia2 <= 300)
@defVar(m, 0 <= Ia3 <= 600)
@defVar(m, 0 <= C1 <= 500)
@defVar(m, 0 <= C2 <= 200)
@defVar(m, 0 <= A1 <= 300)
@defVar(m, 0 <= A2 <= 250)

# Calculations to obtain C Cu Mn, C = Carbon, Cu = Copper, Mn = Manganese
# For example the total amount of C is made up of 2.5% Iron Alloy 1 and 3% of Iron alloy 2
@defExpr(C, 2.5Ia1 + 3Ia2)
@defExpr(Cu, 0.3Ia3 + 90C1 + 96C2 + 0.4A1 + 0.6A2)
@defExpr(Mn, 1.3Ia1 + 0.8Ia2 + 4C2 + 1.2A1)

# Cost
@defExpr(cost, 200Ia1 + 250Ia2 + 150Ia3 + 220C1 + 240C2 + 200A1 + 165A2)

# Total weight
@defExpr(weight, Ia1 + Ia2 + Ia3 + C1 + C2 + A1 + A2)

# Constraint for C Cu Mn grade
@addConstraint(m, 2*order <= C <= 3*order)
@addConstraint(m, 0.4*order <= Cu <= 0.6*order)
@addConstraint(m, 1.2*order <= Mn <= 1.65*order)

# Tons of steel = 500
# Total weight have to be equal to the order
@addConstraint(m, weight == order)

# Objective
@setObjective(m, Min, cost)

status = solve(m)

println("Status = ", status)
println("Ia1 = ", getValue(Ia1)/order*100, "%")
println("Ia2 = ", getValue(Ia2)/order*100, "%")
println("Ia3 = ", getValue(Ia3)/order*100, "%")
println("C1 = ", getValue(C1)/order*100, "%")
println("C2 = ", getValue(C2)/order*100, "%")
println("A1 = ", getValue(A1)/order*100, "%")
println("A2 = ", getValue(A2)/order*100, "%")
println("Weight = ", getValue(weight))
println("Min Cost = " , getObjectiveValue(m))

# Results
# Status = Optimal
# Ia1 = 80.0%
# Ia2 = 0.0%
# Ia3 = 7.9552603984620855%
# C1 = 0.0%
# C2 = 0.552254456483747%
# A1 = 11.492485145054166%
# A2 = 0.0%
# Weight = 500.0
# Min Cost = 98121.63579168123


#=	Explanation
	Explanation of the code is commented before the code
	Result of the composition is printed in percentage
=#	









