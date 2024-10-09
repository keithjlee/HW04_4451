using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10
    model = generate_npod(nlegs, [0, 0, 10])

    #the following should be used as your bounds for SpatialVariables
    dxmin = -0.01
    dxmax = 20.0

    dzmin = -9.9
    dzmax = 10.0
end

visualize_3d(model; show_labels = true)

#=
YOUR CODE BELOW

Hint: Read the README for a walkthrough on structural optimization using AsapOptim.jl
=#