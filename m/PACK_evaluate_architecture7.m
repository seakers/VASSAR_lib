function results = PACK_evaluate_architecture7(arch)
%% PACK_evaluate_architecture7.m
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
%     TRLs = RBES_get_instrument_TRLs(sat_instrs);
%     dev_times = RBES_estimate_instr_dev_times(TRLs);
%     lds(s) = params.startdate + max(dev_times);
%     mission_set{s} = create_test_mission(sat_name,sat_instrs,lds(s),params.lifetime,[]);  
    mission_set{s} = create_test_mission(sat_name,sat_instrs,1991,8,[]);  
end

%% Eval costs
params.ESTIMATE_SCIENCE = 0;
[~,~,~,~,cost_vec,~,~,orbits] = RBES_Evaluate_MissionSet(mission_set);
results.cost = sum(cost_vec);
params.ESTIMATE_SCIENCE = 1;

%% Eval science with trains
unique_orbits = unique(orbits);
ntrains = length(unique_orbits); 
subobjective_scores = cell(ntrains,1);
dc_matrices = cell(ntrains,1);
data_continuity_score_vec=zeros(ntrains,1);

for i = 1:ntrains
    indexes = find(strcmp(orbits,unique_orbits(i)));
    sat_instrs = instr_list(ismember(arch,indexes));
    sat_name = [char(params.satellite_names) '_train_' num2str(i)];
    train = create_test_mission(sat_name,sat_instrs,1990,8,[]);
    if params.DATA_CONTINUITY == 1
        [~,~,~,subobjective_scores{i},data_continuity_score_vec(i),dc_matrices{i},~,~] = RBES_Evaluate_Mission(train);
    else
        [~,~,~,subobjective_scores{i},~,~,~,~] = RBES_Evaluate_Mission(train);
    end
end
% subobjective_scores{end} = set_subobj_score(subobjective_scores{end},'subobj-WAE2-6',1.0);% This is clouds and radiation that requires 3 ceres in 2 different orbits. Must be forced because no train contains all of them
[combined_score,combined_pan,~,combined_subobj] = RBES_combine_subobj_scores(subobjective_scores);
% combined_matrix = RBES_combine_DC_matrices(dc_matrices);
results.science = combined_score;
results.panel_scores = combined_pan;
% nsat = results.nsat;
results.combined_subobjectives = combined_subobj;
results.data_continuity = sum(data_continuity_score_vec);
results.launch_dates = lds;
results.orbits = orbits(arch);
% results.dc_matrix = combined_matrix;
end