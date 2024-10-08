"""
    generate_npod(n, radius = 10; E = 200e6, A = .001)

Make an npod structure.
"""
function generate_npod(n::Integer = 9, free_node_position::Vector{<:Real} = [0, 0, 10], radius = 10; E = 2.1e8, A = .00139, P = [-2.0, 0.0, -5.0])

    @assert length(free_node_position) == 3

    #evenly distribute n points around a circle
    #here we sample n+1 points and exclude the last value because 0 == 2pi
    angle_values = range(0, 2pi, n+1)[1:end-1]

    #get base positions
    x_positions = radius .* cos.(angle_values)
    y_positions = radius .* sin.(angle_values)

    #base nodes
    base_nodes = [TrussNode([x,y,0], [false, false, false], :support) for (x,y) in zip(x_positions, y_positions)]

    #free node
    free_node = TrussNode(Float64.(free_node_position), [true, true, true], :free)

    #collect
    nodes = [base_nodes; free_node]

    #elements
    section = TrussSection(A, E)
    elements = [TrussElement(support, free_node, section) for support in base_nodes]

    #load 
    loads = [NodeForce(free_node, P)]

    #assemble
    model = TrussModel(nodes, elements, loads)
    solve!(model)

    return model
end

function interactive_npod(;n = 9, initial_pos = [0, 0, 10], dxrange = (0, 15), dzrange = (-9.9, 5))

    #make the default npod
    model = generate_npod(n, initial_pos)

    #make spatial variables for the free node
    i_elements = vcat(Asap.nodeids.(model.elements)...)
    i_free_node = findall(model.nodes, :free)[1]
    xvar = SpatialVariable(model.nodes[i_free_node], 0., -1., 1., :X)
    zvar = SpatialVariable(model.nodes[i_free_node], 0., -1., 1., :Z)
    params = TrussOptParams(model, [xvar, zvar])

    #the following uses Observables in Makie.jl to have real-time interactivity
    x = Observable(0.)
    z = Observable(0.)

    #live updating vector of decision variables
    vars = @lift([$x, $z])
    
    #live updating model
    m = @lift(updatemodel(params, $vars))

    #live updating points
    pts = @lift(Point3.(eachrow(node_positions($m))))
    els = @lift($pts[i_elements])

    #live updating force values
    f = @lift(Asap.axial_force.($m.elements))

    #set the color bounds for elements
    colorrange = @lift(maximum(abs.($f)) .* (-1, 1))

    #live updating element lengths
    l = @lift(length.($m.elements))

    #live updating objective
    fl = @lift(dot(abs.($f), $l))

    #turn into a text title
    fl_string = @lift("∑FL = " * string(round($fl, digits = 2)))

    #make figure
    fig = Figure()

    #insert an axis
    ax = Axis3(
        fig[1,1],
        aspect = :data,
        xlabel = "X",
        ylabel = "Y",
        title = fl_string
    )

    #clean up the default decorations
    ax.xticksvisible = ax.yticksvisible = ax.zticksvisible = false
    hidespines!(ax)

    #draw elements
    linesegments!(
        els,
        linewidth = 3,
        color = f,
        colorrange = colorrange,
        colormap = cgrad([:red, :lightgray, :blue])
    )

    #scatter nodes
    scatter!(
        pts,
        color = :white,
        strokecolor = :black,
        strokewidth = 2,
        markersize = 10
    )

    #make sliders
    slg = SliderGrid(
        fig[2,1],
        (label = "ΔX", range = range(dxrange..., 250), startvalue = 0.),
        (label = "ΔZ", range = range(dzrange..., 250), startvalue = 0.)
    )

    #tie slider values to variables
    on(slg.sliders[1].value) do val
        x[] = val
    end

    on(slg.sliders[2].value) do val
        z[] = val
    end

    #return interactive figure
    return fig

end