using JuMP
using Gadfly

m = Model()

# Time
t = 60

# A = Alice, B = Bob
# Positions
@defVar(m, Aposition[1:2,1:t])
@defVar(m, Bposition[1:2,1:t])

# Velocities
@defVar(m, Avelocity[1:2,1:t])
@defVar(m, Bvelocity[1:2,1:t])

# Thruster input
@defVar(m, Athrust[1:2,1:t])
@defVar(m, Bthrust[1:2,1:t])

# Initial Velocity and Position
@addConstraint(m, Aposition[:,1] .== [0,0])
@addConstraint(m, Bposition[:,1] .== [0.5,0]) # Half a mile east

@addConstraint(m, Avelocity[:,1] .== [0,20]) # 20 mph North
@addConstraint(m, Bvelocity[:,1] .== [30,0]) # 30 mph East

# Add functions to calculate position and velocity
cnst = 1/3600
for i in 1:t-1
	@addConstraint(m, Aposition[:,i+1] .== Aposition[:,i] + cnst.*Avelocity[:,i])
	@addConstraint(m, Bposition[:,i+1] .== Bposition[:,i] + cnst.*Bvelocity[:,i])
	@addConstraint(m, Avelocity[:,i+1] .== Avelocity[:,i] + Athrust[:,i])
	@addConstraint(m, Bvelocity[:,i+1] .== Bvelocity[:,i] + Bthrust[:,i])
end

# Meet at the same point at t = 60
@addConstraint(m, Aposition[:,t] .== Bposition[:,t])

# Minimize energy
@setObjective(m, Min, sum(Athrust.^2) + sum(Bthrust.^2))

status = solve(m)

# time = collect(1:1:60)
Apost = getValue(Aposition)
Bpost = getValue(Bposition)

# Print results
println("Alice and Bob's position at time t = 60")
println(Apost[:,60], Bpost[:,60])

# Plot the graph
layer1 = layer(x = Apost[1,:][:], y = Apost[2,:][:], Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = Bpost[1,:][:], y = Bpost[2,:][:], Geom.line, Theme(default_color=color("blue")))

# Draw the graph
Graph1 = plot(layer1, layer2, Guide.title("Hovercraft trajectories"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["Alice", "Bob"], ["red", "blue"]))

draw(PDF("5a.pdf", 8inch, 8inch), Graph1)


#=
	Set up all the variables
	And minimize the energy usage. sum(Athrust.^2) + sum(Bthrust.^2)
	
	Alice and Bob's position
	Alice: [0.4958333333333333,0.16388888888888897]
	Bob:   [0.4958333333333333,0.16388888888888897]
	
	Their position match at time = 60

	More explanation commented in text
=#