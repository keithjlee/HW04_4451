using HW04_4451

#make a model with a centered free node 
model = generate_npod(9, [0, 0, 10])
visualize_model(model)
free_node = model.nodes[10]

#=

make spatial variables using AsapOptim

Note that in AsapOptim, spatial variables are defined using *incremental* positions.
IE if a spatial variable value is 5, it means "+5 from the initial node position" and not "at position 5"
=#

dx0 = 5.
dz0 = -5.

begin
    xvar = SpatialVariable(free_node, dx0, -0.01, 15., :X) # (node, initial value, lowerbound, upperbound, direction)
    zvar = SpatialVariable(free_node, dz0, -9., 5., :Z)

    #collect variables
    variables = [xvar, zvar]

    #make optimization parameters
    params = TrussOptParams(model, variables)

    #initial starting values
    x0 = params.values

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
    OBJ(x0)

    CSTR = x -> constraint_function(x, params)
    CSTR(x0)
end

withgradient(OBJ, x0)

begin
    alg = NLoptAlg(:LD_MMA)
    opts = NLoptOptions(
        maxtime = 60,
        ftol_rel = 1e-12,
        ftol_abs = 1e-12,
        xtol_rel = 1e-8
    )
end

begin
    F = TraceFunction(OBJ)
    opt_model = Nonconvex.Model(F)
    addvar!(opt_model, params.lb, params.ub)
    add_ineq_constraint!(opt_model, CSTR)

    # solve
    optimization_results = Nonconvex.optimize(opt_model, alg, x0, options = opts)
    @show x_opt = optimization_results.minimizer
    @show obj_opt = optimization_results.minimum

    obj_history = getproperty.(F.trace, :output)
    x_history = getproperty.(F.trace, :input)
end

#make new optimized model
optimized_model = updatemodel(params, x_opt)
visualize_model(optimized_model)

lines(obj_history)