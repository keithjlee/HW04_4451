using HW04_4451

# generate a pratt truss of the specified geometry 
model = generate_pratt()
visualize_2d(model; show_labels = true)
interactive_pratt()

#=
optimization
=#

#variable bounds
dymin = -3.0
dymax = 3.0
dy0 = 0.

#centerline nodes
i_center = [4, 10]

#nodes on left side (independent variables)
i_left = [2, 3, 8, 9]

#nodes on right side (mirrors the nodes on left side)
i_right = [6, 5, 12, 11]

#make variables
middle_vars = [SpatialVariable(model.nodes[i], dy0, dymin, dymax, :Y) for i in i_center]

left_vars = [SpatialVariable(model.nodes[i], dy0, dymin, dymax, :Y) for i in i_left]

right_vars = [CoupledVariable(model.nodes[i], parent) for (i, parent) in zip(i_right, left_vars)]

vars = TrussVariable[middle_vars; left_vars; right_vars]

#make optimization parameters
params = TrussOptParams(model, vars)

