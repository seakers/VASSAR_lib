function current_interferences = PACK_get_current_interferences(arch)
global params
indexes = false(length(params.list_of_interfering_pairs),1);
for i = 1:size(params.list_of_interfering_pairs,1)
    instr1 = params.list_of_interfering_pairs{i,1};
    instr2 = params.list_of_interfering_pairs{i,2};
    if are_together(instr1,instr2,arch)
        indexes(i) = true;
    end
end

current_interferences = params.list_of_interfering_pairs(indexes,:);
importances = cell2mat(current_interferences(:,3));
[~,sort_indexes] = sort(importances,'descend');
current_interferences = current_interferences(sort_indexes,:);
end
