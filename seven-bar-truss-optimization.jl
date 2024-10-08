using HW04_4451

#=
Make a 7 bar truss
=#

begin
    dx = 2.
    dy = .5

    x_positions = 0:dx:2dx

    #make the main set of nodes (we constrain the degrees of freedom to the XY plane)
    main_nodes = [TrussNode([x, 0., 0.], [true, true, false], :main) for x in x_positions]

    #make the first node a pin support and update id
    first(main_nodes).dof = [false, false, false]
    first(main_nodes).id = :pin

    #make the last node a roller support and update id
    last(main_nodes).dof = [true, false, false]
    last(main_nodes).id = :roller

    #make the offset set of nodes
    offset_x_positions = [0.5dx, 1.5dx]
    offset_nodes = [TrussNode([x, dy, 0.], [true, true, false], :offset) for x in offset_x_positions]

    #make a cross section
    A = 1e-3 #m²
    E = 200e6 #kN/m²

    section = TrussSection(A, E)

    #make the main elements
    main_elements = [TrussElement(main_nodes[i], main_nodes[i+1], section, :main) for i = 1:2]

    #make the offset element
    offset_elements = [TrussElement(offset_nodes[1], offset_nodes[2], section, :offset)]

    #make the web elements
    web_elements1 = [TrussElement(main, offset, section, :web) for (main, offset) in zip(main_nodes[1:2], offset_nodes)]
    web_elements2 = [TrussElement(main, offset, section, :web) for (main, offset) in zip(main_nodes[2:3], offset_nodes)]

    #collect nodes and elements
    nodes = [main_nodes; offset_nodes]
    elements = [main_elements; offset_elements; web_elements1; web_elements2]

    #make loads
    p = [0., -50., 0.] #50 kN downwards

    loads = [NodeForce(node, p) for node in nodes[:main]]

    #assemble model
    model = TrussModel(nodes, elements, loads)

    #solve for displacements
    solve!(model)
end

#visualize
fig = visualize_2d(model; show_labels = true)

# ylims!(fig.content[1], -dy, 2dy)
# save("readme_figures/7bar_1.png", fig)

#=
OPTIMIZATION
=#

# VARIABLES

#set the bounds for the change in y position
dy_min = -0.25
dy_max = 4.

#initial variable value
dy0 = 0.

#define main variable
var1 = SpatialVariable(model.nodes[4], dy0, dy_min, dy_max, :Y)

#define a coupled variable
var2 = CoupledVariable(model.nodes[5], var1)

#collect variables
vars = TrussVariable[var1, var2]

#=
PARAMETERS, OBJECTIVES, and TESTING
=#

#make parameters
params = TrussOptParams(model, vars)

#initial position
x0 = params.values

#define objective closure
OBJ = x -> objective_FL(x, params)

#test
o0 = OBJ(x0)

#sampling
xrange = range(dy_min, dy_max, 100) #100 samples between our variable bounds
ovalues = [OBJ([x]) for x in xrange]

fig = Figure()
ax = Axis(fig[1,1], xlabel = "ΔY", ylabel = "OBJ")
lines!(xrange, ovalues)
fig

# save("readme_figures/7bar_2.png", fig)


#test gradient
do0 = gradient(OBJ, x0)[1]

#=
OPTIMIZATION
=#

#define algorithm
algorithm = NLoptAlg(:LN_COBYLA)

#solve
res = unconstrained_optimization(x0, params, OBJ, algorithm)

#extract the optimized model
model_opt = res.model_opt
fig = visualize_2d(model_opt)
autolimits!(fig.content[1])
# save("readme_figures/7bar_3.png", fig)

obj_history = res.obj_history

fig = Figure()
ax = Axis(fig[1,1], xlabel = "Iteration", ylabel = "OBJ")
lines!(obj_history)
fig
# save("readme_figures/7bar_4.png", fig)

x_history = [x[1] for x in res.x_history] #this just turns a vector of vectors into a vector of numbers

fig = Figure()
ax = Axis(fig[1,1], xlabel = "ΔY", ylabel = "OBJ")
lines!(xrange, ovalues, color = :gray, label = "Design Space") #we solved this previously from our samplnig
lines!(x_history, obj_history, color = :blue, linewidth = 3, label = "Optimization path")
scatter!(res.x_opt, [res.obj_opt], color = :white, strokecolor = :blue, strokewidth = 2, markersize = 10, label = "Solution")
axislegend(ax)
fig

# save("readme_figures/7bar_5.png", fig)

#=
trying a different starting position and algorithm
=#

x1 = [2.5]
algorithm = NLoptAlg(:LD_MMA)

res = unconstrained_optimization(x1, params, OBJ, algorithm)

#extract the optimized model
model_opt = res.model_opt
fig = visualize_2d(model_opt)
autolimits!(fig.content[1])
# save("readme_figures/7bar_6.png", fig)

obj_history = res.obj_history

fig = Figure()
ax = Axis(fig[1,1], xlabel = "Iteration", ylabel = "OBJ")
lines!(obj_history)
fig
# save("readme_figures/7bar_7.png", fig)

x_history = [x[1] for x in res.x_history] #this just turns a vector of vectors into a vector of numbers

fig = Figure()
ax = Axis(fig[1,1], xlabel = "ΔY", ylabel = "OBJ")
lines!(xrange, ovalues, color = :gray, label = "Design Space") #we solved this previously from our samplnig
lines!(x_history, obj_history, color = :blue, linewidth = 3, label = "Optimization path")
scatter!(res.x_opt, [res.obj_opt], color = :white, strokecolor = :blue, strokewidth = 2, markersize = 10, label = "Solution")
axislegend(ax)
fig

# save("readme_figures/7bar_8.png", fig)