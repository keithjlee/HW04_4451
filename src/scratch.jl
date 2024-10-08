using HW04_4451

function sample_grid(n::Int, num_points::Int, bounds::Vector{Tuple{Float64, Float64}})
    # Ensure that bounds has the same length as the number of dimensions
    @assert length(bounds) == n "The number of bounds must match the number of dimensions"

    # Create a range for each dimension using the specified bounds and the number of points
    ranges = [range(b[1], b[2], length=num_points) for b in bounds]

    # Use Iterators.product to create a Cartesian product of these ranges
    grid_points = collect(Iterators.product(ranges...))
    
    return grid_points
end

ndims = 3
num_points = 3000
bounds = [(-5.0, 10.0), (4.0, 10.), (0, 20)]

begin
    samples = latin_hypercube_sampler(num_points, ndims, bounds)
    pts = Point3.(samples)
    scatter(pts)
end