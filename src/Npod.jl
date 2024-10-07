"""
    generate_npod(n, radius = 10; E = 200e6, A = .001)

Make an npod structure.
"""
function generate_npod(n::Integer, free_node_position::Vector{<:Real}, radius = 10; E = 2.1e8, A = .00139, P = [-2.0, 0.0, -5.0])

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

