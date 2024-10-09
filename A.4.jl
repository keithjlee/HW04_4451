using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 20

    zmin = .1
    zmax = 20

    bounds = [(xmin, xmax), (zmin, zmax)]

    lmin = 10
    lmax = 30

    model = generate_npod(nlegs, [0, 0, 10])
end

visualize_3d(model; show_labels = true)

# perform sampling again
begin
    n_total_samples = 500
    samples_grid = grid_sampler(n_total_samples, 2, bounds)
    x_grid = getindex.(samples_grid, 1)
    z_grid = getindex.(samples_grid, 2)

    fl_grid = Float64[]
    for (x, z) in zip(x_grid, z_grid)
        pos = [x, 0, z]

        sampled_model = generate_npod(nlegs, pos)
        f = Asap.axial_force.(sampled_model.elements)
        l = length.(sampled_model.elements)

        push!(fl_grid, sum(abs.(f) .* l))
    end

    fl_best = minimum(fl_grid)
    i_valid = findall(fl_grid .<= 25*fl_best)

    begin
        fig = Figure()
        ax = Axis3(
            fig[1,1],
            xlabel = "X [m]",
            ylabel = "Z [m]",
            zlabel = "∑|FL|"
        )

        scatter!(
            x_grid[i_valid], z_grid[i_valid], fl_grid[i_valid],
            color = fl_grid[i_valid],
        )

        fig
    end
end


#=
Note that in AsapOptim, spatial variables are defined using *incremental* positions.
IE if a spatial variable value is 5, it means "+5 from the initial node position" and not "at position 5"
=#
begin
    i_free = 10
    xvar = SpatialVariable(model.nodes[i_free], 0., -0.01, 20., :X) # (node, initial value, lowerbound, upperbound, direction)
    zvar = SpatialVariable(model.nodes[i_free], 0., -9.9, 10., :Z)

    #collect variables
    variables = [xvar, zvar]

    #make optimization parameters
    params = TrussOptParams(model, variables)

    #make objective function
    OBJ = x -> objective_FL(x, params)
    CSTR = x -> constraint_lengths(x, params, lmin, lmax)
end

dx0 = 10.
dz0 = -1.

x0 = [dx0, dz0]
res = constrained_optimization(x0, params, OBJ, CSTR, NLoptAlg(:LN_COBYLA))

#make new optimized model
model_opt = updatemodel(params, res.x_opt)
visualize_3d(model_opt)


lines(res.obj_history)