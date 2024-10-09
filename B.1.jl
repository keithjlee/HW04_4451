using HW04_4451

# constants
begin
    model = generate_pratt()
    dymin = -3.0
    dymax = 3.0
end

# visualize the pratt truss with node/element labels
visualize_2d(model; show_labels = true)

#=
YOUR CODE BELOW

Hint: think carefully about indices and the use of `CoupledVariable`s
=#