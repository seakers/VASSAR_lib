function results = PACK_evaluate_architecture5(arch)
%% PACK_evaluate_architecture5.m
global params
r = global_jess_engine();

% This function asserts missions corresponding to the packaging
% architecture given in the input, and then evaluates them

instr_list = params.packaging_instrument_list;

% Clear expl facility
clear explanation_facility

% reset rules engine and asserts deffacts (DATABASE)
r.reset;


%% Assert one Mission per satellite
% pack = arch;
% pack = arch;

ns = max(arch); % number of satellites
mission_set = cell(ns,1);
for s = 1:ns
    sat_instrs = instr_list(arch==s);
    sat_name = [char(params.satellite_names)  num2str(s)];
    mission_set{s} = create_test_mission(sat_name,sat_instrs,1990,8,[]);  
end

%% Eval manifest
[score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores] = RBES_Evaluate_MissionSet(mission_set);
[combined_score,combined_pan,combined_obj,combined_subobj] = RBES_combine_subobj_scores(subobjective_scores);
    
results.science = combined_score;
results.cost = sum(cost_vec);
results.panel_scores = combined_pan;
% nsat = results.nsat;
results.combined_subobjectives = combined_subobj;


end