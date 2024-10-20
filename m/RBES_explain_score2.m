function RBES_explain_score2()
[~,v] = get_all_data('AGGREGATION::SUBOBJECTIVE',{'id'},{'single-char'},0);
subobj_list = unique(cellfun(@char,depack_cellofcells(v),'UniformOutput',false));

% [~,values] = my_jess_query('AGGREGATION::VALUE','satisfaction',0);
[~,values] = get_all_data('AGGREGATION::VALUE',{'satisfaction'},{'single-char'},0);
score= str2double(char(values{1}));
fprintf('Architecture achieves a score of %f because\n',score);
fprintf('************************************************\n');
fprintf('************************************************\n');

for i = 1:length(subobj_list)
    subobj = subobj_list{i};
    [~,values] = my_jess_query(['AGGREGATION::SUBOBJECTIVE (id ' subobj ' )'],'satisfaction',0);
    scores = cellfun(@str2double,cellfun(@char,values,'UniformOutput',false));
    if max(scores) < 1.0      
        RBES_why_not3(subobj);
        fprintf('************************************************\n')
    end
end
end