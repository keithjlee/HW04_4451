"""
    pratt_truss()

This makes a Pratt truss in the correct geometry and topology as required in Problem 2. This is *not* a generalize constructor for any dimensions/discretization
"""
function pratt_truss()
    
    # constants
    span = 12 #m
    A = 1e-3 #m²
    E = 200e6 #kN/m²
    nbays = 6
    dy = 2 #m

    #x positions of all nodes
    xvals = range(0, span, nbays+1)
    
    #main nodes
    main_nodes = [TrussNode([x, 0., 0.], :free, :main) for x in xvals]

    #supports
    fixnode!(first(main_nodes), :pinned) #this is equivalent to main_nodes[1].dof = [false, false, false]
    first(main_nodes).id = :pin
    fixnode!(last(main_nodes), :xfree) #this is equivalent to main_nodes[end].dof = [true, false, false]
    last(main_nodes).id = :roller

    #offset nodes
    offset_nodes = [TrussNode([x, -dy, 0.], :free, :offset) for x in xvals[2:end-1]]

    #elements
    sec = TrussSection(A, E)

    #main
    main_elements = [TrussElement(main_nodes[i], main_nodes[i+1], sec, :main) for i = 1:nbays]

    #offset
    offset_elements = [TrussElement(offset_nodes[i], offset_nodes[i+1], sec, :offset) for i = 1:nbays-2]

    #strut
    strut_elements = [TrussElement(n1, n2, sec, :strut) for (n1, n2) in zip(offset_nodes, main_nodes[2:end-1])]

    #web
    imain = [1, 2, 3, 5, 6, 7]
    ioffset = [1, 2, 3, 3, 4, 5]

    web_elements = [TrussElement(main_nodes[i1], offset_nodes[i2], sec, :web) for (i1, i2) in zip(imain, ioffset)]

    #collect
    nodes = [main_nodes; offset_nodes]
    elements = [main_elements; offset_elements; strut_elements; web_elements]

    #loads
    p = [0., -20., 0.] #kN
    loads = [NodeForce(node, p) for node in nodes[:offset]]

    #collect
    model = TrussModel(nodes, elements, loads)

    #constrain to XY plane
    planarize!(model)

    #solve for displacements
    solve!(model)

    return model

end

function interactive_pratt()

    model = pratt_truss()

    #variable bounds
    dymin = -3.0
    dymax = 3.0
    dy0 = 0.

    #centerline nodes
    i_center = [4, 10]

    #nodes on left side (independent variables)
    i_left = [2, 3, 8, 9]

    #nodes on right side (mirrors the nodes on left side)
    i_right = [6, 5, 12, 11]

    #make variables
    middle_vars = [SpatialVariable(model.nodes[i], dy0, dymin, dymax, :Y) for i in i_center]

    left_vars = [SpatialVariable(model.nodes[i], dy0, dymin, dymax, :Y) for i in i_left]

    right_vars = [CoupledVariable(model.nodes[i], parent) for (i, parent) in zip(i_right, left_vars)]

    vars = TrussVariable[left_vars[1:2]; middle_vars[1]; left_vars[3:4]; middle_vars[2]; right_vars]

    #make optimization parameters
    params = TrussOptParams(model, vars)

    v0 = Observable(0.)
    v1 = Observable(0.)
    v2 = Observable(0.)
    v3 = Observable(0.)
    v4 = Observable(0.)
    v5 = Observable(0.)

    x = @lift([$v0, $v1, $v2, $v3, $v4, $v5])

    m = @lift(updatemodel(params, $x))

    #live updating points
    pts = @lift(Point2.(eachrow(node_positions($m))))

    i_elements = vcat(Asap.nodeids.(model.elements)...)
    els = @lift($pts[i_elements])

    #live updating force values
    f = @lift(Asap.axial_force.($m.elements))

    #set the color bounds for elements
    colorrange = @lift(maximum(abs.($f)) .* (-1, 1))

    #live updating element lengths
    ltot = @lift(sum(length.($m.elements)))

    #compliance
    c = @lift(dot($m.u, params.P))

    #objective
    obj = @lift($c * $ltot)

    #turn into a text title
    obj_string = @lift("f = " * string(round($obj, digits = 2)))

    #figure
    fig = Figure()

    ax = Axis(
        fig[1,1],
        aspect = DataAspect(),
        title = obj_string
    )
    
    #get rid of axes and grid lines
    hidedecorations!(ax)
    hidespines!(ax)

    linesegments!(
        els,
        color = f,
        linewidth = 2,
        colorrange = colorrange,
        colormap = [:red, :lightgray, :blue]
    )

    #plot the nodes
    scatter!(
        pts,
        color = :white,
        strokecolor = :black,
        strokewidth = 2
    )


    slrange = range(dymin, dymax, 250)
    sg = SliderGrid(
        fig[2,1],
        (label = "v0", range = slrange, startvalue = 0),
        (label = "v1", range = slrange, startvalue = 0),
        (label = "v2", range = slrange, startvalue = 0),
        (label = "v3", range = slrange, startvalue = 0),
        (label = "v4", range = slrange, startvalue = 0),
        (label = "v5", range = slrange, startvalue = 0)
    )

    on(sg.sliders[1].value) do val
        v0[] = val
    end

    on(sg.sliders[2].value) do val
        v1[] = val
    end

    on(sg.sliders[3].value) do val
        v2[] = val
    end

    on(sg.sliders[4].value) do val
        v3[] = val
    end

    on(sg.sliders[5].value) do val
        v4[] = val
    end

    on(sg.sliders[6].value) do val
        v5[] = val
    end

    on(x) do _
        autolimits!(ax)
    end

    return fig

end