"""
    random_sampler_2d(n_samples::Integer, dim1bounds, dim2bounds)

Generate an [n × 2] matrix where each row represents a random sample within the specified bounds.

dim1bounds and dim2bounds should either be tuples (e.g. (0, 29)) or vectors (e.g. [-10, 10]) of length 2.
"""
function random_sampler_2d(n_samples::Integer, dim1bounds, dim2bounds)

    #bounds should either be tuples or vectors of length 2
    @assert length(dim1bounds) == length(dim2bounds) == 2

    # extract bounds
    xmin, xmax = dim1bounds
    ymin, ymax = dim2bounds

    # create a random [n x 2] matrix from 0 to 1
    init =  rand(n_samples, 2)

    # scale to bounds
    dim1 = init[:, 1] .* (xmax - xmin) .+ xmin
    dim2 = init[:, 2] .* (ymax - ymin) .+ ymin

    # return scaled [n x 2] matrix of sampled points within bounds
    return [dim1 dim2]
end

"""
    grid_sampler_2d(approx_n_samples::Integer, dim1bounds, dim2bounds)

Generate an [n × 2] matrix where each row represents a grid sample within the specified bounds.
Note that due to the nature of grid sampling, the total number of samples specified may not reflect what is returned.

dim1bounds and dim2bounds should either be tuples (e.g. (0, 29)) or vectors (e.g. [-10, 10]) of length 2.
"""
function grid_sampler_2d(approx_n_samples::Integer, dim1bounds, dim2bounds)

    #bounds should either be tuples or vectors of length 2
    @assert length(dim1bounds) == length(dim2bounds) == 2

    # extract bounds
    xmin, xmax = dim1bounds
    ymin, ymax = dim2bounds

    #take the number of samples per dimension (this may be a non-integer value!)
    n_per_dimension = sqrt(approx_n_samples)

    #round up to nearest integer
    n_per_dimension = Int(ceil(n_per_dimension))

    #sampling range
    sample_range = range(0, 1, n_per_dimension)

    #initialize result matrix
    samples = zeros(n_per_dimension^2, 2)

    #sample, scale, and populate
    row = 1
    for d1 in sample_range
        for d2 in sample_range
            
            x = d1 * (xmax - xmin) + xmin
            y = d2 * (ymax - ymin) + ymin

            samples[row, :] .= [x,y]
            row += 1
        end
    end

    # return scaled [n x 2] matrix of sampled points within bounds
    return samples
end

"""
    latin_hypercube_sampler_2d(n_samples::Integer, dim1bounds, dim2bounds)

Generate an [n × 2] matrix where each row represents a Latin Hypercube sample within the specified bounds.

dim1bounds and dim2bounds should either be tuples (e.g. (0, 29)) or vectors (e.g. [-10, 10]) of length 2.

"""
function latin_hypercube_sampler_2d(n_samples::Integer, dim1bounds, dim2bounds)

    #bounds should either be tuples or vectors of length 2
    @assert length(dim1bounds) == length(dim2bounds) == 2

    # extract bounds
    xmin, xmax = dim1bounds
    ymin, ymax = dim2bounds

    # perform latin hypercube sampling
    init =  randomLHC(n_samples, 2)
    init = init ./ maximum(init, dims = 1)

    # scale to bounds
    dim1 = init[:, 1] .* (xmax - xmin) .+ xmin
    dim2 = init[:, 2] .* (ymax - ymin) .+ ymin

    # return scaled [n x 2] matrix of sampled points within bounds
    return [dim1 dim2]
end