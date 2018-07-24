function p = get_params()
persistent params
if (isempty(params))
    params = RBES_Init_Params_Demo;
end
p = params;
end