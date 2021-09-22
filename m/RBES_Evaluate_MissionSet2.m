function [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores,dc_matrices,orbits,lv_pack_factors] = RBES_Evaluate_MissionSet2(mission_set)
%% RBES_Evaluate_MissionSet.m
%
% Usage:
% [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec] = RBES_Evaluate_MissionSet(mission_set)
%
global params

%% Start
score_vec = zeros(length(mission_set),1);
cost_vec = zeros(length(mission_set),1);
lv_pack_factors= zeros(length(mission_set),1);
orbits = cell(length(mission_set),1);
% panel_scores_mat = zeros(length(mission_set),6);% 6 panels, only for Decadal Objectives
panel_scores_mat = zeros(params.npanels,length(mission_set));% 6 panels, only for EOS Objectives
subobjective_scores = cell(length(mission_set),1);

data_continuity_score_vec = zeros(length(mission_set),1);
lists = cell(length(mission_set),1);
dc_matrices = cell(length(mission_set),1);
for i = 1:length(mission_set)
    if params.TALK
        fprintf('Evaluating mission %d from %d\n',i,length(mission_set));
    end
    mission = mission_set{i};
    if params.ESTIMATE_SCIENCE == 1
        if params.DATA_CONTINUITY == 1 
            [score_vec(i),panel_scores_mat(:,i),~,subobjective_scores{i},data_continuity_score_vec(i),dc_matrices{i},cost_vec(i),orbits{i},lv_pack_factors(i)] = RBES_Evaluate_Mission(mission);
        else
%             [score_vec(i),panel_scores_mat(:,i),~,subobjective_scores{i},~,~,cost_vec(i),orbits{i}] = RBES_Evaluate_Mission(mission);
            
            [orbits{i},~,cost_vec(i),~,lv_pack_factors(i)] = RBES_optimize_orbit(mission.instrument_list,params.potent_orbits,params.orbit_selection_rule,params.orbit_selection_weights);
            data_continuity_score_vec = [];
            dc_matrices = [];
        end
    else
        [~,~,~,~,~,~,cost_vec(i),orbits{i},lv_pack_factors(i)] = RBES_Evaluate_Mission(mission);
    end
    % need to take the max of subobjective_scores with current
    % subobj_scores
%     panel_scores_mat = panel_scores_mat';
    lists{i} = explanation_facility();
    if params.TALK
        fprintf('Mission %d from %d OK: science = %f, cost = %f\n',i,length(mission_set),score_vec(i),cost_vec(i));
    end
end
return