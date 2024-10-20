function missing_objectives = RBES_missing_objectives(obj_list)
%% RBES_missing_objectives.m
global params
missing_objectives = java.util.ArrayList;
for i = 1:params.objectives.size
    obj = params.objectives.get(i-1);
    if ~obj_list.contains(obj)
        missing_objectives.add(obj);
    end
end
end