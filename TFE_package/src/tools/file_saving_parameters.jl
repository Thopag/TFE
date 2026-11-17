export file_1D, file_2D

struct File1D
    u0::Vector{Float64}
    duration::Float64
    VEC_p_model::Vector{ModelParameters}
    VEC_label::Vector{String}
    parameter_label::String
    DIV::String
    with_nociceptor::Bool
    with_projection_neuron::Bool
end

function file_1D(u0, duration, VEC_p_model, VEC_label, parameter_label, DIV, with_nociceptor, with_projection_neuron)
    return File1D(u0, duration, VEC_p_model, VEC_label, parameter_label, DIV, with_nociceptor, with_projection_neuron)
end

#---------------------------------------------------------#

struct File2D
    u0::Vector{Float64}
    duration::Float64
    M_p_model::Matrix{ModelParameters}
    VEC_row_param::Vector{Float64}
    VEC_col_param::Vector{Float64}
    row_label::String
    col_label::String
    DIV::String
    with_nociceptor::Bool
    with_projection_neuron::Bool
end

function file_2D(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, DIV, with_nociceptor, with_projection_neuron)
    return File2D(u0, duration, M_p_model, VEC_row_param, VEC_col_param, row_label, col_label, DIV, with_nociceptor, with_projection_neuron)
end