using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 2radius

    zmin = .1
    zmax = 2radius

    bounds = [(xmin, xmax), (zmin, zmax)]

    lmin = 10
    lmax = 30
end

#sample
n_total_samples = 1000
samples_grid = grid_sampler(n_total_samples, 2, bounds)
xsamples = getindex.(samples_grid, 1)
zsamples = getindex.(samples_grid, 2)

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

fl_best = minimum(fl)
i_valid = findall(fl .<= 50fl_best)

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
        xsamples[i_valid], zsamples[i_valid], fl[i_valid],
        color = pt_colors[i_valid]
    )

    fig
end