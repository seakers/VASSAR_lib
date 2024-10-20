function str = check_consistency_structure(str,col_row)
names = fieldnames(str);
for i = 1:length(names)
    [nrow,ncol] = size(str.(names{i}));
    if strcmp(col_row,'col')        
        if ncol > 1 && nrow == 1
            str.(names{i}) = str.(names{i})';
        end
    elseif strcmp(col_row,'row')
        if ncol == 1 && nrow > 1
            str.(names{i}) = str.(names{i})';
        end
    end
end