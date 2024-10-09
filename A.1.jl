using HW04_4451

#initial exploration
interactive_npod()

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 20

    zmin = .1
    zmax = 20

    bounds = [(xmin, xmax), (zmin, zmax)]

    model = generate_npod(nlegs, [0, 0, 10])
end

#visualize the model you created
visualize_3d(model; show_labels = true)

#=
YOUR CODE BELOW
=#