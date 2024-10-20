function [score,panel_scores,objective_scores,subobjective_scores] = compute_scientific_benefit
global params
r = global_jess_engine();
%% Individual requirement satisfaction
subobjective_scores = cell(size(params.subobjectives));
for p =1:params.npanels
    for o = 1:params.num_objectives_per_panel(p)
        tmp = zeros(length(params.subobjectives{p}{o}),1);
        for so = 1:length(params.subobjectives{p}{o})
            var_name = ['?*' params.subobjectives{p}{o}{so} '*'];
            tmp(so) = r.eval(var_name).floatValue(r.getGlobalContext());
        end
        subobjective_scores{p}{o} = tmp;
    end
end 

%% 2nd level of aggregation
objective_scores = cell(size(params.obj_weights));
for p =1:params.npanels
    for o = 1:params.num_objectives_per_panel(p)
        tmp = params.subobj_weights{p}{o}'*subobjective_scores{p}{o};
        objective_scores{p}(o) = tmp;
    end
end

%% 1st level of aggregation
panel_scores = zeros(params.npanels,1);
for p = 1:params.npanels
    panel_scores(p) = objective_scores{p}*params.obj_weights{p};
end

%% 0th level of aggregation
% dc = jess_value(r.eval('?*science-multiplier*'));% Duty cycle multiplier
dc = 1;% already taken into account at the measurement level
score = dc.*panel_scores'*params.panel_weights;


return