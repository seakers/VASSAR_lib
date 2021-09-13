    function [combined_score,combined_pan,combined_obj,combined_subobj] = RBES_combine_subobj_scores(subobj_cell)
%% RBES_combine_subobj_scores.m
%
% This function combines different subobjective scores obtained by
% different missions that are not cross-registered. 
% The combined subobjective satisfaction matrix is obtained by calculating
% the *maximum* satisfaction of the objective by any mission.
% 
% Usage:
% [score_vec,~,~,~,cost_vec,subobj] = RBES_Evaluate_MissionSet(mission_set);
% combined_subobj = RBES_combine_subobj_scores(subobj);

global params
combined_subobj = cell(size(params.subobjectives));
n = size(subobj_cell,1); % number of missions
no_vec = cellfun(@length, params.obj_weights); % nobj of each panel

if isempty(subobj_cell{1})
    combined_subobj = subobj_cell{2};
elseif isempty(subobj_cell{2})
    combined_subobj = subobj_cell{1};
else
    for p = 1:params.npanels
        no = no_vec(p);
        for o = 1:no
            subobj_po = zeros(length(params.subobjectives{p}{o}),1);
            for m = 1:n
                subobj_pom = subobj_cell{m}{p}{o};% array (nsubobj, 1)
                subobj_po = max(subobj_po,subobj_pom);
            end
            combined_subobj{p}{o} = subobj_po;
        end
    end
end
%% 2nd level of aggregation
combined_obj = cell(size(params.obj_weights));
for p =1:params.npanels
    for o = 1:params.num_objectives_per_panel(p)
        tmp = params.subobj_weights{p}{o}'*combined_subobj{p}{o};
        combined_obj{p}(o) = tmp;
    end
end

%% 1st level of aggregation
combined_pan = zeros(params.npanels,1);
for p = 1:params.npanels
    combined_pan(p) = combined_obj{p}*params.obj_weights{p};
end

%% 0th level of aggregation
combined_score = combined_pan'*params.panel_weights;

end