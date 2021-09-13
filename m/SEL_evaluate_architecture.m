function results = SEL_evaluate_architecture(arch)
%% SEL_evaluate_architecture.m
% This function asserts missions corresponding to the selection
% architecture given in the input, and then evaluates them
% arch = [1 1 0 0 0 1 0 1 0 0] where 1 means that instrument i flies
% all instruments are considered flown separately

global params
% r = global_jess_engine();

% get synergies DSM between selected instruments f rom params.science_DSM
M = params.science_DSM(logical(arch),logical(arch))>0;

% do packaging: put in the same sat all instruments that are synergistic
% this will produce large satellites, this is fine since it's only for the
% purpose of taking synergies into account
assig = getClustersFromAdjacencyMatrix(M);
n = max(assig);% this is the number of missions

all = params.instrument_list;
list = all(logical(arch));
sats = PACK_arch2sats2(list,assig);

% create mission set
mission_set = cell(1,n);
for i = 1:length(sats)
    mission_name = [params.satellite_names num2str(i)];
    %instrument_list = StringArraytoStringWithSpaces(sats{i});
    mission_set{i} = create_test_mission(mission_name,sats{i},1991,8,[]);
end

% evaluate architecture using EvaluateMissionSet 
params.ESTIMATE_COST = 1;
[score_vec,~,~,~,cost_vec,subobj] = RBES_Evaluate_MissionSet(mission_set);

%% Evaluate asserted missions
if strcmp(params.science_metric,'SUM')
    results.science = sum(score_vec);
elseif strcmp(params.science_metric,'MAX')
    [results.science,results.panel_scores,~,~] = RBES_combine_subobj_scores(subobj);
else
end

results.cost = sum(cost_vec);% proxy: number of instruments


%%
end