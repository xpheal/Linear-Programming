using JuMP
using NamedArrays

# Names of senior employees
senior_Employees = ["Manuel"; "Luca"; "Jule"; "Michael"; "Malte"; "Chris"; "Spyros"; "Mirjam"; "Matt";
					"Florian"; "Josep"; "Joel"; "Tom  "; "Daniel"; "Anne"]

# Time slots
time_Slots = ["10:00"; "10:20"; "10:40"; "11:00"; "11:20"; "11:40"; "Lunch"; "1:00"; "1:20"; "1:40"; "2:00"; "2:20"; "2:40"]

# Input of senior employees' available times
doodle_Schedule = [
	0 0 1 1 0 0 0 1 1 0 0 0 0;
	0 1 1 0 0 0 0 0 1 1 0 0 0;
	0 0 0 1 1 0 1 1 0 1 1 1 1;
	0 0 0 1 1 1 1 1 1 1 1 1 0;
	0 0 0 0 0 0 1 1 1 0 0 0 0;
	0 1 1 0 0 0 0 0 1 1 0 0 0;
	0 0 0 1 1 1 1 0 0 0 0 0 0;
	1 1 0 0 0 0 0 0 0 0 1 1 1;
	1 1 1 0 0 0 0 0 0 1 1 0 0;
	0 0 0 0 0 0 0 1 1 0 0 0 0;
	0 0 0 0 0 0 1 1 1 0 0 0 0;
	1 1 0 0 0 1 1 1 1 0 0 1 1;
	1 1 1 0 1 1 0 0 0 0 0 1 1;
	0 1 1 1 0 0 0 0 0 0 0 0 0;
	1 1 0 0 1 1 0 0 0 0 0 0 0;
]

m = Model()

(x,y) = size(doodle_Schedule)
# Create a variable that is the optimized duplicate of the original schedule
@defVar(m, 0 <= optimize_Schedule[1:x, 1:y] <= 1)

# At every time slot, the candidate cannot meet with more that one senior employees
# Except for lunch, where he can meet with 3 senior employees
@addConstraint(m, flow[i in 1:6], sum(optimize_Schedule[:,i]) <= 1)
@addConstraint(m, sum(optimize_Schedule[:,7]) <= 3) # Lunch
@addConstraint(m, flow[i in 8:13], sum(optimize_Schedule[:,i]) <= 1)

# Every senior employees get to meet with the candidate once
@addConstraint(m, flow[i in 1:15], sum(optimize_Schedule[i,:]) >= 1)

# Set objective to maximize the meetup between the candidate and the senior employees
@setObjective(m, Max, vecdot(doodle_Schedule,optimize_Schedule))

status = solve(m)

# Print array result to text file
result = open("result.txt", "w")
writedlm(result,NamedArray(convert(Array{Int64,2},getValue(optimize_Schedule)), (senior_Employees,time_Slots), ("Senior Employees", "Time Slots")))
close(result)

#=
	Explanation
	A feasible interview schedule exist
	
	# Timeslot 	10	102	104	110	112	114	Lun 100	120	140	200	220	240
	# Manuel	0	0	0	1	0	0	0	0	0	0	0	0	0
	# Luca		0	1	0	0	0	0	0	0	0	0	0	0	0
	# Jule		0	0	0	0	0	0	0	0	0	0	0	1	0
	# Michael	0	0	0	0	0	0	1	0	0	0	0	0	0
	# Malte		0	0	0	0	0	0	1	0	0	0	0	0	0
	# Chris		0	0	0	0	0	0	0	0	0	1	0	0	0
	# Spyros	0	0	0	0	1	0	0	0	0	0	0	0	0
	# Mirjam	1	0	0	0	0	0	0	0	0	0	0	0	0
	# Matt		0	0	0	0	0	0	0	0	0	0	1	0	0
	# Florian	0	0	0	0	0	0	0	0	1	0	0	0	0
	# Josep		0	0	0	0	0	0	1	0	0	0	0	0	0
	# Joel		0	0	0	0	0	0	0	1	0	0	0	0	0
	# Tom  		0	0	0	0	0	0	0	0	0	0	0	0	1
	# Daniel	0	0	1	0	0	0	0	0	0	0	0	0	0
	# Anne		0	0	0	0	0	1	0	0	0	0	0	0	0

	Each senior employees only meet with the candidate once
	Each timeslot is only occupied by one senior employees except for lunch
=#