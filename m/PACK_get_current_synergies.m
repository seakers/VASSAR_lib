function current_synergies = PACK_get_current_synergies(arch)
global params
indexes = false(length(params.list_of_synergistic_pairs),1);
for i = 1:size(params.list_of_synergistic_pairs,1)
    instr1 = params.list_of_synergistic_pairs{i,1};
    instr2 = params.list_of_synergistic_pairs{i,2};
    if are_together(instr1,instr2,arch)
        indexes(i) = true;
    end
end

current_synergies = params.list_of_synergistic_pairs(indexes,:);
importances = cell2mat(current_synergies(:,3));
[~,sort_indexes] = sort(importances,'descend');
current_synergies = current_synergies(sort_indexes,:);
end

