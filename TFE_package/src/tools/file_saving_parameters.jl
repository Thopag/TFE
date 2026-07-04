export file_parameters, plan_parameters

struct FileParameters
    u0::Vector{Float64}
    duration::Float64
    VEC_p_model::Vector{ModelParameters}
    VEC_label::Vector{String}
    parameter_label::String
    DIV::String
end

function file_parameters(u0, duration, VEC_p_model, VEC_label, parameter_label, DIV)
    return FileParameters(u0, duration, VEC_p_model, VEC_label, parameter_label, DIV)
end

#---------------------------------------------------------#

struct PlanParameters
    u0::Vector{Float64}
    duration::Float64
    M_p_model::Matrix{ModelParameters}
    VEC_row_param::Vector{Float64}
    VEC_col_param::Vector{Float64}
    row_label::String
    col_label::String
    DIV::String
end

function plan_parameters(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, DIV)
    return PlanParameters(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, DIV)
end