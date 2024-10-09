using HW04_4451

# constants
begin
    model = generate_pratt()
    dymin = -3.0
    dymax = 3.0

    n_total_samples = 20
end

#=
YOUR CODE BELOW

Hint: Use the `TrussOptParams` along with `updatemodel(params, x)` to generate new models from your sampled variables
=#

begin
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
end

bounds = fill((dymin, dymax), 6)
ndims = 6
samples = random_sampler(n_total_samples, ndims, bounds)

models = [updatemodel(params, x) for x in samples]
