%% RBES_map_subobjective_satisfaction.m
global params
r = global_jess_engine();
N = length(params.instrument_list);% num of instruments
% 
% %% Single instruments
% mission_set = cell(N,1);
% for i = 1:N
%     mission_set{i} = create_test_mission(['EOSSingles' num2str(i)],params.instrument_list(i),1990,8,[]);
% end
% jess unwatch all;
% [single_scores,~,~,~,single_costs,subobjective_scores_singles] = RBES_Evaluate_MissionSet(mission_set);% [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cos
% % singles_map = java.util.HashMap;
% % for i = 1:N
% %     singles_map.put(params.instrument_list{i},subobjective_scores);
% % end
% 
% %% Pairs
% kk = 2;% we are interested in pairs
% payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell
% n = size(payloads,1);
% mission_set = cell(n,1);
% for i = 1:n
%     mission_set{i} = create_test_mission(['EOSPairs' num2str(i)],payloads(i,:),1990,8,[]);
% end
% [score_vec,panel_scores_mat,data_continuity_score_vec,lists,cost_vec,pairs_subobjective_scores] = RBES_Evaluate_MissionSet(mission_set);
% % pairwise_scores = zeros(N,N);
% % pairwise_costs = zeros(N,N);
% % pairs_map = java.util.hashmap;% {'instr1','instr2'} ---> subobjective scores structure
% % kk = 1;
% % for i = 1:N
% %     for j = 1:N
% %         if i == j
% %             pairwise_scores(i,j) = 0; % diagonal end
% %         elseif i>j
% %             pairwise_scores(i,j) = pairwise_scores(j,i); 
% %         else
% %             pairwise_scores(i,j) = score_vec(kk);
% %             pairwise_costs(i,j) = cost_vec1(kk);
% %             pairs_map.put(payloads(i,:),subobjective_scores{i});
% %             kk = kk + 1;
% %         end
% %     end
% % end

%% loop over single instruments
map_subobjective_satisfaction = java.util.HashMap;
pnam = params.panel_names;
for i = 1:length(subobjective_scores_singles)
    subobj = subobjective_scores_singles{i};
    for p = 1:params.npanels
        for o = 1:length(subobj{p})
            for so = 1:length(subobj{p}{o})
                score = subobj{p}{o}(so);
                if score == 1
                    str = [pnam{p} num2str(o) '-' num2str(so)];
                    if ~map_subobjective_satisfaction.containsKey(str)
                        map_subobjective_satisfaction.put(str,params.instrument_list(i));
                    else
                    end                   
                end
            end
        end
        
    end
end

%% loop over pairs
kk = 2;% we are interested in pairs
payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell

for i = 1:length(pairs_subobjective_scores)
    subobj = pairs_subobjective_scores{i};
    for p = 1:params.npanels
        for o = 1:length(subobj{p})
            for so = 1:length(subobj{p}{o})
                score = subobj{p}{o}(so);
                if score == 1
                    str = [pnam{p} num2str(o) '-' num2str(so)];
                    if ~map_subobjective_satisfaction.containsKey(str)
                        map_subobjective_satisfaction.put(str,payloads(i));
                    else
                    end                   
                end
            end
        end
        
    end
end