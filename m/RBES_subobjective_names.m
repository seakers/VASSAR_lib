function names = RBES_subobjective_names()
global params
if isfield(params,'subobjective_names')
    names = params.subobjective_names;
else
    names = cell(RBES_count_subobj(),1);
    n = 1;
    for p =1:params.npanels
        for o = 1:params.num_objectives_per_panel(p)
            for so = 1:length(params.subobjectives{p}{o})
                names{n} = params.subobjectives{p}{o}{so};
                n = n + 1;
            end
        end
    end
    params.subobjective_names = names;
end

end