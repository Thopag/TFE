export file_parameters

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