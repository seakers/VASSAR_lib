function n = RBES_count_subobj()
global params
if isfield(params,'num_subobjectives')
    n = params.num_subobjectives;
else
    n = 0;
    for p =1:params.npanels
        for o = 1:params.num_objectives_per_panel(p)
            for so = 1:length(params.subobjectives{p}{o})
                n = n + 1;
            end
        end
    end
    params.num_subobjectives = n;
end

end