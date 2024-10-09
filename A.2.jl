using HW04_4451

# problem constants
begin
    nlegs = 9
    radius = 10

    xmin = 0.
    xmax = 20

    zmin = .1
    zmax = 20

    bounds = [(xmin, xmax), (zmin, zmax)]

    lmin = 10
    lmax = 30

    model = generate_npod(nlegs, [0, 0, 10])

    n_total_samples = 1000
end