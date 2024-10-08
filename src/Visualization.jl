function visualize_3d(model::TrussModel; show_labels = false)

    #extract node positions
    nodes = node_positions(model)

    #flatten the vectors of start/end node indices of each element [[istart, iend], [istart,iend]...]
    element_indices = vcat(Asap.nodeids.(model.elements)...)

    #turn them into vectors of Point3's from GLMakie
    pts = Point3.(eachrow(nodes))
    els = pts[element_indices]

    #get the axial forces
    f = Asap.axial_force.(model.elements)

    #find the maximum magnitude force
    fmax = maximum(abs.(f))

    #set the colorrange based on these forces
    cr = (-1, 1) .* fmax

    #figure
    fig = Figure()
    ax = Axis3(
        fig[1,1],
        aspect = :data
    )

    #get rid of axes and grid lines
    hidedecorations!(ax)
    hidespines!(ax)

    #plot the element lines
    #replace color = f with color = :black to get all black lines
    linesegments!(
        els,
        color = f,
        # color = :black,
        colorrange = cr,
        linewidth = 2,
        colormap = cgrad([:red, :lightgray, :blue])
    )

    #plot the nodes
    scatter!(
        pts,
        color = :white,
        strokecolor = :black,
        strokewidth = 2
    )

    if show_labels

        element_labels = ["E$i" for i = 1:model.nElements]
        node_labels = ["N$i" for i = 1:model.nNodes]

        e_midpoints = Point3.(midpoint.(model.elements))

        text!(pts, text = node_labels, color = :black)
        text!(e_midpoints, text = element_labels, color = :gray)

    end


    #return the figure
    return fig
end

function visualize_2d(model::TrussModel; show_labels = false)

    #extract node positions
    nodes = node_positions(model)

    #flatten the vectors of start/end node indices of each element [[istart, iend], [istart,iend]...]
    element_indices = vcat(Asap.nodeids.(model.elements)...)

    #turn them into vectors of Point3's from GLMakie
    pts = Point2.(eachrow(nodes))
    els = pts[element_indices]

    #get the axial forces
    f = Asap.axial_force.(model.elements)

    #find the maximum magnitude force
    fmax = maximum(abs.(f))

    #set the colorrange based on these forces
    cr = (-1, 1) .* fmax

    #figure
    fig = Figure()
    ax = Axis(
        fig[1,1],
        aspect = DataAspect()
    )

    ymax = maximum(abs.(nodes[:, 2]))
    ylims!(-1.5ymax, 1.5ymax)


    #get rid of axes and grid lines
    hidedecorations!(ax)
    hidespines!(ax)

    #plot the element lines
    #replace color = f with color = :black to get all black lines
    linesegments!(
        els,
        color = f,
        # color = :black,
        colorrange = cr,
        linewidth = 2,
        colormap = cgrad([:red, :lightgray, :blue])
    )

    #plot the nodes
    scatter!(
        pts,
        color = :white,
        strokecolor = :black,
        strokewidth = 2
    )

    if show_labels

        element_labels = ["E$i" for i = 1:model.nElements]
        node_labels = ["N$i" for i = 1:model.nNodes]

        e_midpoints = Point2.(midpoint.(model.elements))

        text!(pts, text = node_labels, color = :black)
        text!(e_midpoints, text = element_labels, color = :gray)

    end

    #return the figure
    return fig
end