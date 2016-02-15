using JuMP

m = Model()

demand = [43, 40, 36, 36, 35, 38, 41, 46, 49, 48, 47, 47, 48, 46, 45, 47, 50, 63, 75, 75, 72, 66, 57, 50]

limit = 65

costLow = 100
costHigh = 400
capacity = 30

# @defVar(m, cost[1:24] >= 0)
@defVar(m, 0 <= usage[1:24] <= 65)
@defVar(m, x[1:24] >= 0)
@defVar(m, y[1:24] <= 0)
@defVar(m, charge[1:24] <= 0)
@defVar(m, used[1:24] >= 0)
@defVar(m, b[1:25] >= 0)

@addConstraint(m, b[1] == 0)
@addConstraint(m, flow[i in 1:24], b[i] - charge[i] - used[i] == b[i + 1])
@addConstraint(m, flow[i in 1:24], usage[i] + charge[i] + used[i] == demand[i])
@addConstraint(m, flow[i in 1:24], x[i] + y[i] + 50 == usage[i])

# for i = 1:24
# 	@addConstraint(m, cost[i] == usage[i] * costLow)
# end

@defExpr(totalCost, costHigh * sum(x) + costLow * (50 * 24 + sum(y)))
@setObjective(m, Min, totalCost)

status = solve(m)

println(getObjectiveValue(m))

println(convert(Array{Int64,1}, getValue(b)))
println(convert(Array{Int64,1}, getValue(charge)))
println(convert(Array{Int64,1}, getValue(used)))
println(convert(Array{Int64,1}, getValue(usage)))
# println(totalCost)
