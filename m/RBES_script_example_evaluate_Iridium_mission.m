%% RBES_script_example_evaluate_Iridium_mission.m

RBES_Init_Params_Iridium;% Creates params
[r,params] = RBES_Init_WithRules(params);
instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY'};
mission = RBES_Create_Mission('s/c', 'POL_800km', instrument_list,params);
[r,score,panel_scores,objective_scores,subobjective_scores] = RBES_Evaluate_Mission(r,mission,params);

