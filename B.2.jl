using HW04_4451

# constants
begin
    model = generate_pratt()
    dymin = -3.0
    dymax = 3.0

    n_total_samples = 20
end

#=
YOUR CODE BELOW

Hint: Use the `TrussOptParams` along with `updatemodel(params, x)` to generate new models from your sampled variables
=#