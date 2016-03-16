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

# Moving Average model
# Generate the A array
k = 5 # Recent inputs
A = zeros(t,k)

for i = 1:k
	A[i:t,i] = u_input[1:t-i+1]
end

# Calculate result
MA = A\y_output
MA_output = A*MA

# Error in the Moving Average Model
MaxWidth = 99
MA_err = zeros(MaxWidth)
for width = 1:MaxWidth
    A = zeros(t,width)
    for i = 1:width
        A[i:t,i] = u_input[1:t-i+1]
    end
    MAout = A\y_output
    yout = A*MAout
    MA_err[width] = norm(y_output-yout)
end

# Autoregressive model
# Generate the A array
k = 5 # Recent inputs
A = zeros(t,k)

for i = 1:k
	A[i+1:t,i] = y_output[1:t-i]
end

# Calculate result
AR = A\y_output
AR_output = A*AR

# Error in the Autoregressive model, max number of recent inputs = 99
MaxWidth = 99
AR_err = zeros(MaxWidth)
for width = 1:MaxWidth
    A = zeros(t,width)
    for i = 1:width
        A[i+1:t,i] = y_output[1:t-i]
    end
    ARout = A\y_output
    yout = A*ARout
    AR_err[width] = norm(y_output-yout)
end


# Plot the result with layers
layer1 = layer(x = x_axis, y = u_input, Geom.line, Theme(default_color=color("red")))
layer2 = layer(x = x_axis, y = y_output, Geom.line, Theme(default_color=color("orange")))
layer3 = layer(x = x_axis, y = MA_output, Geom.line, Theme(default_color=color("blue")))
layer4 = layer(x = x_axis, y = AR_output, Geom.line, Theme(default_color=color("green")))
layer5 = layer(x = x_err_axis, y = MA_err, Geom.line, Theme(default_color=color("purple")))
layer6 = layer(x = x_err_axis, y = AR_err, Geom.line, Theme(default_color=color("brown")))

MA_Graph = plot(layer2, layer3, Guide.title("MA model"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["y output", "MA output"], ["orange", "blue"]))
AR_Graph = plot(layer2, layer4, Guide.title("AR model"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["y output", "AR output"], ["orange", "green"]))
MAAR_Graph = plot(layer3, layer4, Guide.title("MA model against AR model"), Guide.xlabel("x"), Guide.ylabel("y"), Guide.manual_color_key("Legend", ["MA output", "AR output"], ["blue", "green"]))
errorGraph = plot(layer5, layer6, Guide.title("Error of the models compared to original y"), Guide.xlabel("x"), Guide.ylabel("Error"), Guide.manual_color_key("Legend", ["MA error", "AR error"], ["purple", "brown"]))


# Draw result to pdf
draw(PDF("MAARresult.pdf", 8inch, 8inch), MAAR_Graph)
draw(PDF("ARresult.pdf", 8inch, 8inch), AR_Graph)
draw(PDF("MAresult.pdf", 8inch, 8inch), MA_Graph)
draw(PDF("Error.pdf", 8inch, 8inch), errorGraph)

#=
    Explanation
    This program calculate the output using (MA)Moving Average model and (AR)Autoregressive model
    1) By using Ax = y, I generate the "A" and then use "A\y" to obtain the x
    2) The x is then multiplied with A again to obtain the predicted "y" using both models
    Then, the result is plotted in the graph

    The difference between the predicted result and the original result is plotted in the error graph
    The error graph is plotted using 1:99 recent inputs
    As more inputs are included in the MA or AR model, the error decreases and the accuracy increases

    MA_Graph: Result for the MA model
    AR_Graph: Result for the AR model
    MAAR_Graph: Compare MA model to AR model
    errorGraph: Difference between the models output and the original output when you increase the number of recent inputs    

    More explanation are in the comments
=#