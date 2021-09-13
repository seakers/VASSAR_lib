%% run_sensitivity_analysis_Decadal.m
% RBES_Init_Params_Decadal
% [r,params] = RBES_Init_WithRules(params);
n = length(params.instrument_list);
SA_results_Decadal = cell(n,1);
for i = 1:n
    instr = params.instrument_list{i};
    fprintf('Sensitivity Analysis of %s...\n',instr);
    tmp = RBES_sensitivity_analysis_instrument_attributes(r, params, instr);
    SA_results_Decadal{i} = tmp;
end