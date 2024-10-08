using HW04_4451

#make a model with a centered free node 
model = generate_npod(9, [0, 0, 10])
visualize_3d(model; show_labels = true)
i_free = 10

#=

make spatial variables using AsapOptim

Note that in AsapOptim, spatial variables are defined using *incremental* positions.
IE if a spatial variable value is 5, it means "+5 from the initial node position" and not "at position 5"
=#

begin
    xvar = SpatialVariable(model.nodes[i_free], 0., -0.01, 15., :X) # (node, initial value, lowerbound, upperbound, direction)
    zvar = SpatialVariable(model.nodes[i_free], 0., -9., 10., :Z)

    #collect variables
    variables = [xvar, zvar]

    #make optimization parameters
    params = TrussOptParams(model, variables)

    #make objective function
    function objective_function(x, p)
        results = solve_truss(x, p)
        forces = AsapOptim.axial_force(results, p)

        dot(results.L, abs.(forces))
    end

    function constraint_function(x, p)
        geo = GeometricProperties(x, p)

        l = geo.L

        return [
            (l .- 40);
            -l .+ 10
        ]
    end

    #make a closure to make the function a single-argument function
    OBJ = x -> objective_function(x, params)
    CSTR = x -> constraint_function(x, params)
end

dx0 = 7.5
dz0 = 0.

x0 = [dx0, dz0]
res = unconstrained_optimization(x0, params, OBJ, NLoptAlg(:LN_COBYLA))

res = constrained_optimization(x0, params, OBJ, CSTR, NLoptAlg(:LN_COBYLA))

#make new optimized model
visualize_3d(res.model_opt)
lines(res.obj_history)