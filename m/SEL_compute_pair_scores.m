function [pair_scores,pair_costs] = SEL_compute_pair_scores(options)
global params

%% Recompute or retrieve results
% %%%%%%%%%%%%%%%%%%%%
% recompute results %%
% %%%%%%%%%%%%%%%%%%%%
if isempty(options.get_results_from) 
    N = length(params.instrument_list);% num of instruments
    kk = 2;% we are interested in pairs
    payloads = combnk(params.instrument_list,kk);% this is a (N*(N-1),2) cell
    n = size(payloads,1);
    mission_set = cell(n,1);
    for i = 1:n
        mission_set{i} = create_test_mission(['EOSPairs' num2str(i)],payloads(i,:),1990,8,[]);
    end
    jess unwatch all;
%   % %%%%%%%%%%%%%%
%   % WITH SYNERGIES
%   % %%%%%%%%%%%%%%
    if options.with_synergies == 1 || options.with_synergies == 3
        params.CROSS_REGISTER = 1;
        [score_vec1,~,~,~,cost_vec1] = RBES_Evaluate_MissionSet(mission_set);
        pairwise_scores = zeros(N,N);
        pairwise_costs = zeros(N,N);
        kk = 1;
        for i = 1:N
            for j = 1:N
                if i == j
                    pairwise_scores(i,j) = 0; % diagonal end
                elseif i>j
                    pairwise_scores(i,j) = pairwise_scores(j,i); 
                else
                    pairwise_scores(i,j) = score_vec1(kk);
                    pairwise_costs(i,j) = cost_vec1(kk);
                    kk = kk + 1;
                end
            end
        end
    end
%   % %%%%%%%%%%%%%%%%%
%   % WITHOUT SYNERGIES
%   % %%%%%%%%%%%%%%%%%    
    if options.with_synergies == 2 || options.with_synergies == 3
%         params.CROSS_REGISTER = 0;
%         [~,~,~,~,cost_vec2] = RBES_Evaluate_MissionSet(mission_set);

        pairwise_scores_nosyn = zeros(N,N);
        pairwise_costs_nosyn = zeros(N,N);
        kk = 1;
        for i = 1:N
%             tmp{1} = params.instrument_list{i};
%             mission = create_test_mission(tmp{1},tmp,1990,8,[]);
%             [~,~,~,subobjective_scores1,~,~,~] = RBES_Evaluate_Mission(mission);
            
            for j = 1:N
                if i == j
                    pairwise_scores_nosyn(i,j) = 0; % diagonal end
                elseif i>j
                    pairwise_scores_nosyn(i,j) = pairwise_scores_nosyn(j,i); 
                else
%                     mission = create_test_mission(tmp{1},tmp,1990,8,[]);
%                     [~,~,~,subobjective_scores2,~,~,~] = RBES_Evaluate_Mission(mission);
%                     subobj_cell{1} = subobjective_scores1;
%                     subobj_cell{2} = subobjective_scores2;
                    tmp{1} = params.instrument_list{i};
                    two_missions{1} = create_test_mission(tmp{1},tmp,1990,8,[]);
                    tmp{1} = params.instrument_list{j};
                    two_missions{2} = create_test_mission(tmp{1},tmp,1990,8,[]);
                    
                    [~,~,~,~,cost_vec2,subobjective_scores] = RBES_Evaluate_MissionSet(two_missions);           
                    [combined_score,~,~,~] = RBES_combine_subobj_scores(subobjective_scores);
                    
%                     [combined_score,~,~,~] = RBES_combine_subobj_scores(subobj_cell);
%                     pairwise_scores_nosyn(i,j) = score_vec2(kk);
                    pairwise_scores_nosyn(i,j) = combined_score;
                    pairwise_costs_nosyn(i,j) = sum(cost_vec2);
                    kk = kk + 1;
                end
            end
        end
    end  
else % get results from previously saved file
% %%%%%%%%%%%%%%%%%%%%
% retrieve results %%%
% %%%%%%%%%%%%%%%%%%%%
    load(options.get_results_from);
end

%% Compile results
if options.with_synergies == 1 % with synergies
    pair_scores = pairwise_scores;
    pair_costs = pairwise_costs;
elseif options.with_synergies == 2 % no synergyes only
    pair_scores = pairwise_scores_nosyn;
    pair_costs = pairwise_costs_nosyn;
elseif options.with_synergies == 3 % no synergyes only % S-DSM
    pair_scores = pairwise_scores - pairwise_scores_nosyn;
    pair_costs = pairwise_costs - pairwise_costs_nosyn;
end
    