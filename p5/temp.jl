# this array stores the task names (:a, :b, ..., :x)
tasks = []
for i = Int('a'):Int('x')
    push!(tasks, symbol(Char(i)))
end

# this dictionary stores the project durations
dur = [0 4 2 4 6 1 2 3 2 4 10 3 1 2 3 2 1 1 2 3 1 2 5 0]
duration = Dict(zip(tasks,dur))

# this dictionary stores the projects that a given project depends on (ancestors)
pre = ( [], [:a], [:b], [:c], [:d], [:c], [:f], [:f], [:d], [:d,:g], [:i,:j,:h], [:k],
    [:l], [:l], [:l], [:e], [:p], [:c], [:o,:t], [:m,:n], [:t], [:q,:r], [:v], [:s,:u,:w])
pred = Dict(zip(tasks,pre));

using JuMP
m = Model()

@defVar(m, tstart[tasks] >= 0 )
@addConstraint(m, link[i in tasks,j in pred[i]], tstart[i] >= tstart[j] + duration[j])
@setObjective(m, Min, tstart[:x] + duration[:x])

solve(m)
println(pred)
# println(getValue(tstart))