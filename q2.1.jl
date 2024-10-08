using HW04_4451

# generate the pratt truss
model = pratt_truss()

interactive_pratt()

# visualize the pratt truss with node/element labels
visualize_2d(model; show_labels = true)

#design variables are SpatialVariables in the y direction
dymin = -3.0
dymax = 3.0
dy0 = 0.0

# these are the node indices in corresponding order to the HW figure
i_independent_nodes = [2, 3, 4, 8, 9, 10] #v0, v1, v2, v3, v4, v5

independent_variables = [SpatialVariable(model.nodes[i], dy0, dymin, dymax, :Y) for i in i_independent_nodes]

# these are the node indices of the right half of the structure that should be coupled to the independent variable values on the left half
i_right_nodes = [5, 6, 11, 12]

# these are the indices in `i_independent_nodes` corresponding to the mirrored values in i_right_nodes
i_right_targets = [2, 1, 5, 4]

dependent_variables = [CoupledVariable(model.nodes[i], independent_variables[j]) for (i,j) in zip(i_right_nodes, i_right_targets)]

#collect all variables
vars = TrussVariable[independent_variables; dependent_variables]

#make optimization parameters
params = TrussOptParams(model, vars)
x0 = params.values

#make objective function closure
OBJ = x -> objective_energy(x, params)

#test objective
o0 = OBJ(x0)

#
alg = NLoptAlg(:LN_BOBYQA) # Bounded Optimization BY Quadratic Approximation - BOBYQA (derivative free)
# alg = NLoptAlg(:LD_LBFGS) # Low-Storage Broyden-Fletcher-Goldfarb-Shanno - L-BFGS

res = unconstrained_optimization(params, OBJ, alg)
@show res.time

lines(res.obj_history)
visualize_2d(res.model_opt)