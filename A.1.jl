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

Hint: get the axial forces of model elements via:

axial_force = Asap.axial_force(model.elements[1]) # for a single element
axial_forces = Asap.axial_force.(model.elements) # for all elements

And get the lengths of elements via:
element_lengths = length.(model.elements)
=#