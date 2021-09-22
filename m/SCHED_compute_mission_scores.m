function results = SCHED_compute_mission_scores()
%% SCHED_compute_mission_scores.m

global params
n = params.SCHEDULING_num_missions;
mission_set = cell(n,1);
for i = 1:n
     mission_set{i} = create_test_mission(params.SCHEDULING_MissionNames{i},params.SCHEDULING_MissionPayloads{i}, ...
         params.startdate,params.SCHEDULING_MissionLifetimes.get(params.SCHEDULING_MissionNames{i}),[],params.SCHEDULING_partnerships(i));
end
[score_vec,panel_scores_mat,~,~,cost_vec,subobjective_scores,dc_matrices,~] = RBES_Evaluate_MissionSet(mission_set);

%% Update params structure
params.SCHEDULING_MissionScores = java.util.HashMap;
params.SCHEDULING_MissionMatrices = java.util.HashMap;

for i = 1:n
    params.SCHEDULING_MissionScores.put(params.SCHEDULING_MissionNames{i},panel_scores_mat(:,i));
    params.SCHEDULING_MissionMatrices.put(params.SCHEDULING_MissionNames{i},dc_matrices{i});
end

params.SCHEDULING_mission_panel_scores = panel_scores_mat';
params.SCHEDULING_MissionCosts = cost_vec;
params.SCHEDULING_mission_scores = score_vec;
params.SCHEDULING_mission_subobjective_scores = subobjective_scores;

%% Output results
results.scores = score_vec;
results.panel_scores = panel_scores_mat;
results.costs = cost_vec;
results.subobjective_scores = subobjective_scores;

end