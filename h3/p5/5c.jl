using JuMP
using Gadfly

m = Model()

# Time
t = 60

# A = Alice, B = Bob
# Waypoint coordinates
@defVar(m, wayPoint[1:2])

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

@addConstraint(m, Avelocity[:,1] .== [20,0]) # 20 mph North
@addConstraint(m, Bvelocity[:,1] .== [30,0]) # 30 mph East

# Add functions to calculate position and velocity
cnst = 1/3600
for i in 1:t-1
	@addConstraint(m, Aposition[:,i+1] .== Aposition[:,i] + cnst.*Avelocity[:,i])
	@addConstraint(m, Bposition[:,i+1] .== Bposition[:,i] + cnst.*Bvelocity[:,i])
	@addConstraint(m, Avelocity[:,i+1] .== Avelocity[:,i] + Athrust[:,i])
	@addConstraint(m, Bvelocity[:,i+1] .<= Bvelocity[:,i] + Bthrust[:,i])
	# Don't exceed speed limit
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

layer1 = layer(x = Apost[1,:][:], y = Apost[2,:][:], Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = Bpost[1,:][:], y = Bpost[2,:][:], Geom.line, Theme(default_color=color("blue")))

Graph1 = plot(layer1, layer2, Guide.title("Hovercraft trajectories"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["Alice", "Bob"], ["red", "blue"]))

