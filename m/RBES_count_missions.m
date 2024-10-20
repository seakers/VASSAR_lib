function [ns,MissionIds] = RBES_count_missions()
    MissionIds = java.util.HashMap;
    [~,names] = get_all_data('MANIFEST::Mission',{'Name'},{'single-char'},0);
    ns = length(names);
    for i =1:ns
        MissionIds.put(char(names{i}),i);
    end
end