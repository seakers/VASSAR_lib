function [single_scores,single_costs,subobjective_scores,panel_scores] = SEL_compute_single_scores(options)
global params

%% Recompute or retrieve results
% %%%%%%%%%%%%%%%%%%%%
% recompute results %%
% %%%%%%%%%%%%%%%%%%%%
if isempty(options.get_results_from)    
    N = length(params.instrument_list);% num of instruments
    mission_set = cell(N,1);
    for i = 1:N
        mission_set{i} = create_test_mission(['EOSSingles' num2str(i)],params.instrument_list(i),1990,8,[]);
    end
    jess unwatch all
    [single_scores,panel_scores,~,~,single_costs,subobjective_scores] = RBES_Evaluate_MissionSet(mission_set);% [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores]
else
    % %%%%%%%%%%%%%%%%%%%%
    % retrieve results %%%
    % %%%%%%%%%%%%%%%%%%%%
    load(options.get_results_from);
    
end