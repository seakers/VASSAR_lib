%% RBES_script_example_evaluate_Decadal_mission.m

RBES_Init_Params_Decadal;% Creates params
[r,params] = RBES_Init_WithRules(params);
load  names;
instrument_list = names;
mission = RBES_Create_Mission('s/c', 'POL_800km', instrument_list,params);
[r,score,panel_scores,objective_scores,subobjective_scores] = RBES_Evaluate_Mission(r,mission,params);

