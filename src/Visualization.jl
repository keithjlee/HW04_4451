function visualize_model(model::TrussModel)

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

    #return the figure
    return fig
end