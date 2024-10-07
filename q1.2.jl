using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 2radius

    xbounds = (xmin, xmax)

    zmin = 2.
    zmax = 2radius

    zbounds = (zmin, zmax)

    lmin = 10
    lmax = 30
end

#sample
n_total_samples = 1000
samples_grid = grid_sampler_2d(n_total_samples, xbounds, zbounds)
xsamples = samples_grid[:, 1]
zsamples = samples_grid[:, 2]

fl = Float64[]
lengths_violated = Bool[]

for (x, z) in zip(xsamples, zsamples)
    pos = [x, 0, z]

    model = generate_npod(nlegs, pos)
    f = Asap.axial_force.(model.elements)
    l = length.(model.elements)

    push!(fl, sum(abs.(f) .* l))

    if any(l .< lmin) || any(l .> lmax)
        push!(lengths_violated, true)
    else
        push!(lengths_violated, false)
    end
end

#assign a colour depending on if the length constraitns were violated
pt_colors = [violation ? :red : :blue for violation in lengths_violated]

#note that the following is equivalent:
pt_colors = []
for violation in lengths_violated
    if violation == true
        push!(pt_colors, :red)
    else
        push!(pt_colors, :blue)
    end
end

#plot
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
        color = pt_colors
    )

    fig
end