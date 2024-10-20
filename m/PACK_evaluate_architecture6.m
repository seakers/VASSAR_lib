function results = PACK_evaluate_architecture6(arch)
%% PACK_evaluate_architecture6.m
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
lds = zeros(ns,1);
for s = 1:ns
    sat_instrs = instr_list(arch==s);
    sat_name = [char(params.satellite_names)  num2str(s)];
    TRLs = RBES_get_instrument_TRLs(sat_instrs);
    dev_times = RBES_estimate_instr_dev_times(TRLs);
    lds(s) = params.startdate + max(dev_times);
    mission_set{s} = create_test_mission(sat_name,sat_instrs,lds(s),params.lifetime,[]);  
end

%% Eval manifest
[score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores,dc_matrices] = RBES_Evaluate_MissionSet(mission_set);
[combined_score,combined_pan,combined_obj,combined_subobj] = RBES_combine_subobj_scores(subobjective_scores);
% combined_matrix = RBES_combine_DC_matrices(dc_matrices);
results.science = combined_score;
results.cost = sum(cost_vec);
results.panel_scores = combined_pan;
% nsat = results.nsat;
results.combined_subobjectives = combined_subobj;
results.data_continuity = sum(data_continuity_score_vec);
results.launch_dates = lds;
% results.dc_matrix = combined_matrix;
end