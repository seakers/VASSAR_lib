%% SEL_compute_pairwise_scores.m
% RBES_Init_Params_EOS;
% [r,params] = RBES_Init_WithRules(params);
% THIS IS UNUSED (Dani, Feb 15th 2012)
N = length(params.instrument_list);% num of instruments
kk = 2;% we are interested in pairs
payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell
n = size(payloads,1);
mission_set = cell(n,1);
for i = 1:n
    mission_set{i} = create_test_mission(['EOSPairs' num2str(i)],payloads(i,:),1990,8,[]);
end
jess unwatch all

% %% with synergies
% [r,score_vec1,panel_scores_mat1,data_continuity_score_vec1,lists1,cost_vec1] = RBES_Evaluate_MissionSet(r,mission_set,params);
% 
% 
% pairwise_panel_scores_mat = panel_scores_mat1;
% 
% pairwise_scores = zeros(N,N);
% pairwise_costs = zeros(N,N);
% pairwise_synergies = zeros(N,N);
% kk = 1;
% for i = 1:N
%     for j = 1:N
%         if i == j
%             pairwise_scores(i,j) = 0; % diagonal end
%         elseif i>j
%             pairwise_scores(i,j) = pairwise_scores(j,i); 
%         else
%             pairwise_scores(i,j) = score_vec1(kk);
%             pairwise_costs(i,j) = cost_vec1(kk);
%             kk = kk + 1;
%         end
%     end
% end

%% without synergies
[r,score_vec2,panel_scores_mat2,data_continuity_score_vec2,lists1,cost_vec2] = RBES_Evaluate_MissionSet(r,mission_set,params);


pairwise_panel_scores_mat_nosyn = panel_scores_mat1;
pairwise_scores_nosyn = zeros(N,N);
pairwise_costs_nosyn = zeros(N,N);
pairwise_synergies_nosyn = zeros(N,N);
kk = 1;
for i = 1:N
    for j = 1:N
        if i == j
            pairwise_scores_nosyn(i,j) = 0; % diagonal end
        elseif i>j
            pairwise_scores_nosyn(i,j) = pairwise_scores_nosyn(j,i); 
        else
            pairwise_scores_nosyn(i,j) = score_vec2(kk);
            pairwise_costs_nosyn(i,j) = cost_vec2(kk);
            kk = kk + 1;
        end
    end
end


