using JuMP

m = Model()
@defVar(m, 0 <= f <= 1000)           # football trophies
@defVar(m, 0 <= s <= 1500)           # soccer trophies
@addConstraint(m, 4f + 2s <= 4800)   # total board feet of wood
@addConstraint(m, f + s <= 1750)     # total number of plaques
@setObjective(m, Max, 12f + 9s)      # maximize profit
status = solve(m)

println(status)
println("Build ", getValue(f), " football trophies.")
println("Build ", getValue(s), " soccer trophies.")
println("Total profit will be \$", getObjectiveValue(m))