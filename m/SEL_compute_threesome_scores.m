%% SEL_compute_threesome_scores.m
% RBES_Init_Params_EOS;
% [r,params] = RBES_Init_WithRules(params);
global params
N = length(params.instrument_list);% num of instruments
kk = 3;% we are interested in pairs
payloads = combnk(params.instrument_list,kk);% this is a (C(N,k),k) cell
n = size(payloads,1);
mission_set = cell(n,1);
for i = 1:n
    mission_set{i} = create_test_mission(['EOSThrees' num2str(i)],payloads(i,:),1990,8,[]);
end
jess unwatch all

%% with synergies
params.CROSS_REGISTER = 1;
[threesome_scores,panel_scores_mat1,data_continuity_score_vec1,lists1,threesome_costs] = RBES_Evaluate_MissionSet(mission_set);

save EOS_3some_scores_withsyn threesome_scores threesome_costs lists1

%% without synergies
% params.CROSS_REGISTER = 0;
% [r,threesome_scores_nosyn,panel_scores_mat2,data_continuity_score_vec2,lists2,threesome_costs_nosyn] = RBES_Evaluate_MissionSet(r,mission_set,params);
% 
% save EOS_3some_scores_nosyn threesome_scores_nosyn threesome_costs_nosyn lists2


