function int_mask = get_mask_from_instruments(instr_subset,instr_list)
persistent list
if ~ischar(instr_list)
    % initialize with instrument list
    list = instr_list;
    int_mask = 1;
else
    % comes from Jess
    subset =  strsplit(instr_subset,' ');
    mask = zeros(1,length(list));
    for i = 1:length(subset)
        %index = list.get(instr_subset{i});
        index = cellfun(@(x)strcmp(x,subset{i}),list);
        mask(index) = 1;
    end
    int_mask = bi2de(mask);
%     fprintf('instr_subset: %s ==> mask = %d\n',instr_subset,int_mask);
end
end 