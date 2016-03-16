using Gadfly

# import data set
raw = readdlm("uy_data.csv",',');
(m,n) = size(raw)

# Get the y and u data
u_input = raw[:,1]
y_output = raw[:,2]
t = length(u_input)

# for graph plotting
x_axis = collect(1:1:t)
x_err_axis = collect(1:1:t-1)

# Autoregressive Moving Average model
# Generate the A array
k = 1 # Recent inputs
A = zeros(t,2k)

for i = 1:k
	A[i:t,i] = u_input[1:t-i+1] # MA part
    A[i+1:t,i+k] = y_output[1:t-i] # AR part
end

# Calculate result
ARMA = A\y_output
ARMA_output = A*ARMA

# Error in the Autoregressive Moving Average model, max number of recent inputs = 99
MaxWidth = 99
ARMA_err = zeros(MaxWidth)
for width = 1:MaxWidth
    A = zeros(t,2width)
    for i = 1:width
        A[i:t,i] = u_input[1:t-i+1] # MA part
        A[i+1:t,i+width] = y_output[1:t-i] # AR part
    end
    ARMAout = A\y_output
    yout = A*ARMAout
    ARMA_err[width] = norm(y_output-yout)
end


# Plot the result with layers
layer1 = layer(x = x_axis, y = u_input, Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = x_axis, y = y_output, Geom.line, Theme(default_color=color("orange")))
layer3 = layer(x = x_axis, y = ARMA_output, Geom.line, Theme(default_color=color("blue")))
layer5 = layer(x = x_err_axis, y = ARMA_err, Geom.line, Theme(default_color=color("purple")))

ARMA_Graph = plot(layer2, layer3, Guide.title("ARMA model"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["y output", "ARMA output"], ["orange", "blue"]))
errorGraph = plot(layer5, Guide.title("Error of the ARMA model compared to original y"), Guide.xlabel("x"), Guide.ylabel("Error"), Guide.manual_color_key("Legend", ["ARMA error"], ["purple"]))


# Draw result to pdf
draw(PDF("ARMAresult.pdf", 8inch, 8inch), ARMA_Graph)
draw(PDF("ARMAError.pdf", 8inch, 8inch), errorGraph)

#=
    Explanation
    This program calculate the output using the (ARMA)Autoregressive Moving Average Model
    The method is similar to the AR and MA model, Ax = b
    To combine both models into one, I double the size of the array for "x"
    [MA weights, AR weights]
    And also double the width for "A" to include both models
    MA  .   .   .   AR  .   .   .
    .   .   .   .   .   .   .   .   
    .   .   .   .   .   .   .   .   
    .   .   .   .   .   .   .   .   
    .   .   .   .   .   .   .   .   

    After plotting the error graph, it can be seen that ARMA model has higher accuracy compare to just the
    AR or MA model
    ARMA_Graph: result for the ARMA model compared to the original output
    errorGraph: Difference between the ARMA model with the original output by increasing the number of recent inputs

    More explanation are in the comments
=#