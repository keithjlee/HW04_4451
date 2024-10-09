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

=#

n_total_samples = 500
cull_factor = 25

#=
RANDOM SAMPLING
=#

samples_random = random_sampler(n_total_samples, 2, bounds)
x_random = [sample[1] for sample in samples_random]
z_random = [sample[2] for sample in samples_random]

fl_random = Float64[]
for (x,z) in zip(x_random, z_random)
    pos = [x, 0, z]
    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl_random, sum(abs.(f) .* l))
end

fl_best = minimum(fl_random)
i_valid = findall(fl_random .<= cull_factor*fl_best)

begin
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        xlabel = "X [m]",
        ylabel = "Z [m]",
        zlabel = "∑|FL|",
    )

    scatter!(
        x_random[i_valid], z_random[i_valid], fl_random[i_valid],
        color = fl_random[i_valid],
    )

    fig
end

# save("designspace_random_n$n_total_samples.png", fig)

#=
GRID SAMPLING
=#

samples_grid = grid_sampler(n_total_samples, 2, bounds)
x_grid = getindex.(samples_grid, 1)
z_grid = getindex.(samples_grid, 2)

fl_grid = Float64[]
for (x, z) in zip(x_grid, z_grid)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl_grid, sum(abs.(f) .* l))
end

fl_best = minimum(fl_grid)
i_valid = findall(fl_grid .<= cull_factor*fl_best)

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


# save("designspace_grid_n$n_total_samples.png", fig)

#=
LATIN HYPERCUBE SAMPLING
=#

samples_latin = latin_hypercube_sampler(n_total_samples, 2, bounds)
x_latin = getindex.(samples_random, 1)
z_latin = getindex.(samples_random, 2)

fl_latin = Float64[]
for (x, z) in zip(x_latin, z_latin)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl_latin, sum(abs.(f) .* l))
end

fl_best = minimum(fl_latin)
i_valid = findall(fl_latin .<= cull_factor*fl_best)

begin
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        xlabel = "X [m]",
        ylabel = "Z [m]",
        zlabel = "∑|FL|"
    )

    scatter!(
        x_latin[i_valid], z_latin[i_valid], fl_latin[i_valid],
        color = fl_latin[i_valid],
    )

    fig
end

# save("designspace_hypercube_n$n_total_samples.png", fig)