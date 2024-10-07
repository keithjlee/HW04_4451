using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 15

    xbounds = (xmin, xmax)

    zmin = 1
    zmax = 15

    zbounds = (zmin, zmax)
end

n_total_samples = 500

#=
RANDOM SAMPLING
=#

samples_random = random_sampler_2d(n_total_samples, xbounds, zbounds)
xsamples = samples_random[:, 1]
zsamples = samples_random[:, 2]

fl = Float64[]
for (x,z) in zip(xsamples, zsamples)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl, sum(abs.(f) .* l))
end

begin
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        xlabel = "X [m]",
        ylabel = "Z [m]",
        zlabel = "∑|FL|"
    )

    scatter!(
        xsamples, zsamples, fl,
        color = fl,
    )

    fig
end

# save("designspace_random_n$n_total_samples.png", fig)

#=
GRID SAMPLING
=#

samples_grid = grid_sampler_2d(n_total_samples, xbounds, zbounds)
xsamples = samples_grid[:, 1]
zsamples = samples_grid[:, 2]

fl = Float64[]
for (x, z) in zip(xsamples, zsamples)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl, sum(abs.(f) .* l))
end

begin
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        xlabel = "X [m]",
        ylabel = "Z [m]",
        zlabel = "∑|FL|"
    )

    scatter!(
        xsamples, zsamples, fl,
        color = fl,
    )

    fig
end

# save("designspace_grid_n$n_total_samples.png", fig)

#=
LATIN HYPERCUBE SAMPLING
=#

samples_hypercube = latin_hypercube_sampler_2d(n_total_samples, xbounds, zbounds)
xsamples = samples_hypercube[:, 1]
zsamples = samples_hypercube[:, 2]

fl = Float64[]
for (x, z) in zip(xsamples, zsamples)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl, sum(abs.(f) .* l))
end

begin
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        xlabel = "X [m]",
        ylabel = "Z [m]",
        zlabel = "∑|FL|"
    )

    scatter!(
        xsamples, zsamples, fl,
        color = fl,
        colormap = :viridis
    )

    fig
end

# save("designspace_hypercube_n$n_total_samples.png", fig)