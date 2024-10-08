using HW04_4451

model = generate_npod()

fig = visualize_3d(model)
save("readme_figures/npod.png", fig)

fig = visualize_3d(model; show_labels = true)
save("readme_figures/npod_labels.png", fig)

#sampling
n_dimensions = 3
n_samples = 1000

xmin = -5
xmax = 10.25

ymin = 0
ymax = 5

zmin = 12.5
zmax = 18

bounds = [(xmin, xmax), (ymin, ymax), (zmin, zmax)]

samples = random_sampler(n_samples, n_dimensions, bounds)

x = [sample[1] for sample in samples]
y = [sample[2] for sample in samples]
z = [sample[3] for sample in samples]

fig = Figure()
ax = Axis3(fig[1,1], xlabel = "X", ylabel = "Y", zlabel = "Z")

scatter!(x, y, z)

fig

save("readme_figures/sampling.png", fig)

n_dimensions = 2
n_samples = 500

bounds = [(-10, 10), (-10, 10)]

samples = grid_sampler(n_samples, n_dimensions, bounds)

x = getindex.(samples, 1)
y = getindex.(samples, 2)

fig = Figure()
ax = Axis(fig[1,1], xlabel = "X", ylabel = "Y", title = "Grid Sample")

scatter!(x, y, color = sin.(x) .* cos.(y), colormap = :plasma)

fig

save("readme_figures/sampling2.png", fig)

n_dimensions = 2
n_samples = 1000
bounds = [(-pi, pi), (-pi, pi)]
samples = grid_sampler(n_samples, n_dimensions, bounds)

x1 = [sample[1] for sample in samples]
x2 = [sample[2] for sample in samples]

function func(var1, var2)
    return sin(var1) * cos(var2) / (sqrt(var1^2 + var2^2))
end

obj = func.(x1, x2)

fig = Figure()
ax = Axis3(fig[1,1], xlabel = "X1", ylabel = "X2", zlabel = "f(x1,x2)")
scatter!(x1, x2, obj, color = obj, colormap = :viridis)

fig

save("readme_figures/culling.png", fig)

max_value = 0.10
i_valid = findall(obj .<= max_value)

x1valid = x1[i_valid]
x2valid = x2[i_valid]
objvalid = obj[i_valid]

fig = Figure()
ax = Axis3(fig[1,1], xlabel = "X1", ylabel = "X2", zlabel = "f(x1,x2)")
scatter!(x1valid, x2valid, objvalid, color = objvalid, colormap = :viridis)

save("readme_figures/culling2.png", fig)

fig = interactive_npod()
save("readme_figures/interactivenpod.png", fig)

pratt = generate_pratt()
fig= visualize_2d(pratt; show_labels = true)
save("readme_figures/pratt.png", fig)

fig = interactive_pratt()
save("readme_figures/interactivepratt.png", fig)