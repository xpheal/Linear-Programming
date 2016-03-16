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
	# Don't exceed speed limit, 35mph
	@addConstraint(m, Avelocity[:,i+1] .<= 35)
	@addConstraint(m, Bvelocity[:,i+1] .<= 35)
end

# Meet at the same point at t = 60
@addConstraint(m, Aposition[:,t] .== Bposition[:,t])

# Same velocity when they meet
@addConstraint(m, Avelocity[:,t] .== Bvelocity[:,t])

# Minimize energy
@setObjective(m, Min, sum(Athrust.^2) + sum(Bthrust.^2))

status = solve(m)

# time = collect(1:1:60)
Apost = getValue(Aposition)
Bpost = getValue(Bposition)
Avelo = getValue(Avelocity)
Bvelo = getValue(Bvelocity)

# Print results
println("Alice and Bob's position at time t = 60")
println(Apost[:,60], Bpost[:,60])

println("Alice and Bob's velocity at time t = 60")
println(Avelo[:,60], Bvelo[:,60])

# Find the maximum velocity for Alice
xMax = Avelo[1,1]
yMax = Avelo[2,1]
for i in 2:t
	if Avelo[1,i] > xMax
		xMax = Avelo[1,i]
	end
	if Avelo[2,i] > yMax
		yMax = Avelo[2,i]
	end
end

# Find the maximum velocity for Bob
xMaxB = Bvelo[1,1]
yMaxB = Bvelo[2,1]
for i in 2:t
	if Bvelo[1,i] > xMaxB
		xMaxB = Bvelo[1,i]
	end
	if Bvelo[2,i] > yMaxB
		yMaxB = Bvelo[2,i]
	end
end

println("Alice 's Maximum X velocity: ", xMax)
println("Alice's Maximum Y velocity: ", yMax)
println("Bob's Maximum X velocity: ", xMaxB)
println("Bob's Maximum Y velocity: ", yMaxB)


layer1 = layer(x = Apost[1,:][:], y = Apost[2,:][:], Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = Bpost[1,:][:], y = Bpost[2,:][:], Geom.line, Theme(default_color=color("blue")))

Graph1 = plot(layer1, layer2, Guide.title("Hovercraft trajectories"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["Alice", "Bob"], ["red", "blue"]))

draw(PDF("5c.pdf", 8inch, 8inch), Graph1)


#=
	Explanation
	Alice and Bob's position at time t = 60
	Alice: [0.4169163728826559,0.16388888887321684]
	Bob:   [0.4169163728826559,0.16388888887321684]
	They meet at the same spot but it's different from part A and B

	Alice and Bob's velocity at time t = 60
	They meet at the same velocity
	Alice: [8.361238933777926,9.999999998547896]
	Bob:   [8.361238933777926,9.999999998547896]

	Both Alice's and Bob's maximum velocity is less than 35mph
	Alice 's Maximum X velocity: 34.99999999975082
	Alice's Maximum Y velocity: 20.0
	Bob's Maximum X velocity: 30.0
	Bob's Maximum Y velocity: 13.448275860774023
=#