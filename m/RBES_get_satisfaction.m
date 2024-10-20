function scores = RBES_get_satisfaction
    [~,values] = my_jess_query('AGGREGATION::VALUE','satisfaction');
    scores.value = str2double(char(values{1}));
    
    [~,values] = my_jess_query('AGGREGATION::STAKEHOLDER','satisfaction');
    scores.sh_scores = cellfun(@str2double,cellfun(@char,values,'UniformOutput',false));
    
    [~,values] = my_jess_query('AGGREGATION::OBJECTIVE','satisfaction');
    scores.obj_scores = cellfun(@str2double,cellfun(@char,values,'UniformOutput',false));
    
    [~,values] = my_jess_query('AGGREGATION::SUBOBJECTIVE','satisfaction');
    scores.subobj_scores = cellfun(@str2double,cellfun(@char,values,'UniformOutput',false));
end