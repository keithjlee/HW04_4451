"""
    objective_FL(x, p::TrussOptParams)

Proxy for total structural volume assuming fully stressed design:
    ∑|Fᵢ|Lᵢ for i = 1:nelements
"""
function objective_FL(x, p::TrussOptParams)

    #solve for global displacements
    res = solve_truss(x, p)

    #get the axial forces in the elements
    f = AsapOptim.axial_force(res, p)

    #equivalent to Lᵀ|f|
    return dot(res.L, abs.(f))
end

"""
    objective_energy(x, p::TrussOptParams)

Proxy for stiffness to weight ratio.
    uᵀp × ∑Lᵢ
"""
function objective_energy(x, p::TrussOptParams)

    #solve for global displacements
    res = solve_truss(x, p)

    #get the total strain energy or compliance: uᵀp
    strain_energy = dot(res.U, p.P)

    #get the sum of all lengths: ∑Lᵢ
    summed_lengths = sum(res.L)

    #return the product
    return strain_energy * summed_lengths
end

"""
    constraint_lengths(x, p::TrussOptParams, lmin, lmax)

Constrain element lengths to ensure:
    lmin ≤ Lᵢ ≤ lmax
"""
function constraint_lengths(x, p::TrussOptParams, lmin, lmax)

    #get the geometric properties of a structure
    geo = GeometricProperties(x, p)

    #return such that any positive value indicates a violated constraint
    return [
        (geo.L .- lmax);
        (-geo.L .+ lmin)
    ]

end