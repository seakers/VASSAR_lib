%% RBES_script_example_evaluate_Spectral_Bands.m

RBES_Init_Params_Spectral_Bands;% Creates params
[r,params] = RBES_Init_WithRules(params);
n = length(params.instrument_list);
score = zeros(1,n);
panel_scores = zeros(6,n);
for i = 1:n
    instrument_list{1} = params.instrument_list{i};
    mission = RBES_Create_Mission('s/c', 'POL_800km', instrument_list,params);
    [r,score(i),panel_scores(:,i),objective_scores,subobjective_scores] = RBES_Evaluate_Mission(r,mission,params);
end


