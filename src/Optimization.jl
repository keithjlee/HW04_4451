struct OptResults{P,T}
    time::Float64
    params::P
    model_opt::Union{TrussModel, Asap.Model}
    x_opt::Vector{Float64}
    obj_opt::Float64
    cstr_opt::T
    x_history::Vector{Vector{Float64}}
    obj_history::Vector{Float64}
    cstr_history::Vector{T}
    opt_alg::NonconvexNLopt.NLoptAlg
    opt_options::NonconvexNLopt.NLoptOptions
    opt_stop_type::Symbol
end

Base.length(res::OptResults) = length(res.obj_history)

function constrained_optimization(x0::Vector{Float64}, params::P, objective_function::Function, constraint_function::Function, algorithm::NonconvexNLopt.NLoptAlg; optimization_options::NonconvexNLopt.NLoptOptions = NLoptOptions(maxtime = 60), show_status = true) where {P<:Union{TrussOptParams, FrameOptParams}}

    # wrap objective function into TraceFunction to story intermediate values
    F = Nonconvex.TraceFunction(objective_function)

    # optimization model
    opt_model = Nonconvex.Model(F)

    # add variables
    Nonconvex.addvar!(opt_model, params.lb, params.ub)

    # add constraints
    Nonconvex.add_ineq_constraint!(opt_model, constraint_function)

    show_status && println("OPTIMIZING")

    # perform optimization
    opt_clock_time = @elapsed begin
        opt_results = Nonconvex.optimize(
            opt_model, 
            algorithm, 
            x0, 
            options = optimization_options
            )
    end

    show_status && println("SOLVED; POST-PROCESSING")

    # post processing
    x_opt = opt_results.minimizer
    obj_opt = opt_results.minimum
    cstr_opt = constraint_function(x_opt)
    model_opt = updatemodel(params, x_opt)

    # extracting traces
    x_trace = getproperty.(F.trace, :input)
    obj_trace = getproperty.(F.trace, :output)
    cstr_trace = [constraint_function(x) for x in x_trace]

    # populate
    return OptResults{P, typeof(cstr_opt)}(
        opt_clock_time, 
        params, 
        model_opt, 
        x_opt, 
        obj_opt, 
        cstr_opt, 
        x_trace, 
        obj_trace, 
        cstr_trace, 
        algorithm, 
        optimization_options, 
        opt_results.status
        )
end

function constrained_optimization(params::P, objective_function::Function, constraint_function::Function, algorithm::NonconvexNLopt.NLoptAlg; optimization_options::NonconvexNLopt.NLoptOptions = NLoptOptions(maxtime = 60), show_status = true) where {P<:Union{TrussOptParams, FrameOptParams}}
    return constrained_optimization(params.values, params, objective_function, constraint_function, algorithm; optimization_options = optimization_options, show_status = show_status)
end

function unconstrained_optimization(x0::Vector{Float64}, params::P, objective_function::Function, algorithm::NonconvexNLopt.NLoptAlg; optimization_options::NonconvexNLopt.NLoptOptions = NLoptOptions(maxtime = 60), show_status = true) where {P<:Union{TrussOptParams, FrameOptParams}}

    # wrap objective function into TraceFunction to story intermediate values
    F = Nonconvex.TraceFunction(objective_function)

    # optimization model
    opt_model = Nonconvex.Model(F)

    # add variables
    Nonconvex.addvar!(opt_model, params.lb, params.ub)

    show_status && println("OPTIMIZING")

    # perform optimization
    opt_clock_time = @elapsed begin
        opt_results = Nonconvex.optimize(
            opt_model, 
            algorithm, 
            x0, 
            options = optimization_options
            )
    end

    show_status && println("SOLVED; POST-PROCESSING")

    # post processing
    x_opt = opt_results.minimizer
    obj_opt = opt_results.minimum
    model_opt = updatemodel(params, x_opt)

    # extracting traces
    x_trace = getproperty.(F.trace, :input)
    obj_trace = getproperty.(F.trace, :output)

    # populate
    return OptResults{P, Nothing}(
        opt_clock_time, 
        params, 
        model_opt, 
        x_opt, 
        obj_opt, 
        nothing, 
        x_trace, 
        obj_trace, 
        [nothing], 
        algorithm, 
        optimization_options, 
        opt_results.status
        )
end

function unconstrained_optimization(params::P, objective_function::Function, algorithm::NonconvexNLopt.NLoptAlg; optimization_options::NonconvexNLopt.NLoptOptions = NLoptOptions(maxtime = 60), show_status = true) where {P<:Union{TrussOptParams, FrameOptParams}}
    return unconstrained_optimization(params.values, params, objective_function, algorithm; optimization_options = optimization_options, show_status = show_status)
end