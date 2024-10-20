function [] = RBES_params_remove_field(field)
global params
params = rmfield(params,field);
end