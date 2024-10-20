function [S_DSM,E_DSM,single_scores,single_costs,single_subobjective_scores,pair_scores,pair_costs,pairs_subobjective_scores] = RBES_update_DSMs()
global params
N = length(params.instrument_list);% num of instruments
RBES_set_parameter('WATCH_ONLY','no');
if strcmp('CASE_STUDY','IRIDIUM')
    orbit = get_Iridium_orbit();
else
    orbit = [];
end

%% Compute single scores
disp('Computing single instrument scores...');
mission_set = cell(N,1);

for i = 1:N
    mission_set{i} = create_test_mission(['Singles' num2str(i)],params.instrument_list(i),params.startdate,params.lifetime,orbit);
end
[single_scores,~,~,~,single_costs,single_subobjective_scores] = RBES_Evaluate_MissionSet2(mission_set);% [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,subobjective_scores]

%% Compute pair scores (with synergies)
disp('Computing pair scores with synergies...');
kk = 2;% we are interested in pairs
payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell
n = size(payloads,1);
mission_set = cell(n,1);
for i = 1:n
    mission_set{i} = create_test_mission(['Pairs' num2str(i)],payloads(i,:),params.startdate,params.lifetime,orbit);
end
[score_vec1,~,~,~,cost_vec1,pairs_subobjective_scores] = RBES_Evaluate_MissionSet2(mission_set);
pair_scores = zeros(N,N);
pair_costs = zeros(N,N);

kk = 1;
for i = 1:N
    for j = 1:N
        if i < j
            pair_scores(i,j) = score_vec1(kk);
            pair_costs(i,j) = cost_vec1(kk);
            kk = kk + 1;
        end
    end
end

%% Compute pair scores without synergies (combined)
disp('Computing pair scores without synergies...');
% pairwise_scores_nosyn = zeros(N,N);
S_DSM = zeros(N,N);

pairwise_costs_nosyn = zeros(N,N);
n = 1;
for i = 1:N
    for j = 1:N
        if i < j
%             subobjective_scores = {single_subobjective_scores{i};single_subobjective_scores{j}};
%             [pairwise_scores_nosyn(i,j),~,~,~] = RBES_combine_subobj_scores(subobjective_scores);
            ind1 = find(strcmp(params.instrument_list,payloads{n,1}),1);
            ind2 = find(strcmp(params.instrument_list,payloads{n,2}),1);
            S_DSM(ind1,ind2) = RBES_compute_synergy(payloads{n,1},payloads{n,2},0);
            pairwise_costs_nosyn(i,j) = single_costs(i) + single_costs(j);
            n = n + 1;
        end
    end
end

%% Compute S_DSM and E_DSM
disp('Computing DSMs...');
% S_DSM = pair_scores - pairwise_scores_nosyn;
filepath = params.path_save_results;
RBES_graph_DSM(params.instrument_list,S_DSM,'green-only',[filepath 'S_DSM.gv']);
E_DSM = pair_costs - pairwise_costs_nosyn;
RBES_graph_DSM(params.instrument_list,-E_DSM,'red-only',[filepath 'E_DSM.gv']);
end
        