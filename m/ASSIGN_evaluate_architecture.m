function results = ASSIGN_evaluate_architecture(arch)
%% ASSIGN_evaluate_architecture.m
global params
r = global_jess_engine();

% This function asserts missions corresponding to the packaging
% architecture given in the input, and then evaluates them
instr_list = params.assign_instrument_list;

% Clear expl facility
clear explanation_facility

%% Assert one satellite per orbit
ns = length(params.orbit_list); % number of satellites
mission_set = cell(ns,1);
adj_matrix = ASSIGN_arch_to_adj_mat(arch);
jess defglobal ?*instr-copies* = 0;
jess bind ?*instr-copies* (bag create my-bag2);

for i = 1:length(instr_list)
    r.eval(['(bag set ?*instr-copies* ' instr_list{i} ' ' num2str(sum(adj_matrix(i,:))) ')']);
end

for s = 1:ns
    sat_instrs = instr_list(adj_matrix(:,s)==1);
    sat_name = [char(params.satellite_names)  num2str(s)];
    orbit =  get_orbit_struct_from_string(params.orbit_list{s});
    mission_set{s} = create_test_mission(sat_name,sat_instrs,params.startdate,params.lifetime,orbit);  
end

%% Eval costs and best orbits
[score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores] = RBES_Evaluate_MissionSet(mission_set);
[combined_score,combined_pan,combined_obj,combined_subobj] = RBES_combine_subobj_scores(subobjective_scores);
    
results.science = combined_score;
results.cost = sum(cost_vec);
end