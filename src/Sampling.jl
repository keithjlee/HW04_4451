"""
    random_sampler(nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}; ndiscretize = 1000) where {T<:Real, R<:Real}

Generate `nsamples` randomly sampled points of `ndims` dimensions where each dimension has lower and upper bounds specified by `bounds`.

E.g.:

```julia
ndims = 2
nsamples = 100
bounds = [(-4, 10.75), (5, 20)]

samples = random_sampler(nsamples, ndims, bounds)
```
"""
function random_sampler(nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}; ndiscretize = 1000) where {T<:Real, R<:Real}

    @assert ndims == length(bounds) "Bounds must be specified for each dimension"

    #generate random sampling range
    sampling_ranges = [range(b[1], b[2], ndiscretize) for b in bounds]

    #randomly sample within each range
    return [rand.(sampling_ranges) for _ = 1:nsamples]
end

"""
    grid_sampler(approx_nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}) where {T<:Real, R<:Real}

Generate `approx_nsamples` grid sampled points of `ndims` dimensions where each dimension has lower and upper bounds specified by `bounds`. The total number of samples will be ≥ `approx_nsamples` to ensure a consistent grid sampling

E.g.:

```julia
ndims = 3
nsamples = 1000
bounds = [(-4, 10.75), (5, 20), (1, 10)]

samples = grid_sampler(nsamples, ndims, bounds)
```
"""
function grid_sampler(approx_nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}) where {T<:Real, R<:Real}

    @assert ndims == length(bounds) "Bounds must be specified for each dimension"

    #take the number of samples per dimension (this may be a non-integer value!)
    n_per_dimension = approx_nsamples^(1/ndims)

    #round up to nearest integer (minimum of 2)
    n_per_dimension = max(2, Int(ceil(n_per_dimension)))

    #sampling range
    sampling_ranges = [range(b[1], b[2], n_per_dimension) for b in bounds]

    #sample, flatten, and return
    samples = collect.(Iterators.product(sampling_ranges...))[:]

    return samples
end

"""
    latin_hypercube_sampler(nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}) where {T<:Real, R<:Real}

Generate `nsamples` latin hypercube sampled points of `ndims` dimensions where each dimension has lower and upper bounds specified by `bounds`.

E.g.:

```julia
ndims = 3
nsamples = 500
bounds = [(-4, 10.75), (5, 20), (0, 1)]

samples = random_sampler(nsamples, ndims, bounds)
```
"""
function latin_hypercube_sampler(nsamples::Integer, ndims::Integer, bounds::Vector{Tuple{T, R}}) where {T<:Real, R<:Real}

    @assert ndims == length(bounds) "Bounds must be specified for each dimension"

    # perform latin hypercube sampling
    init =  randomLHC(nsamples, ndims)

    # normalize
    init = init ./ maximum(init, dims = 1)

    # scale to bounds
    lowerbounds = (getindex.(bounds, 1))'
    upperbounds = (getindex.(bounds, 2))'

    samples = init .* (upperbounds .- lowerbounds) .+ lowerbounds

    return [Vector(row) for row in eachrow(samples)]
end