function subobj_scores = RBES_get_array_subobj_scores(subobjective_scores)
global params
w = subobjective_scores;
np = length(w);
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
subobj_scores = zeros(1000,1);
ii = 1;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = subobjective_scores{p}{o};
        for so = 1:length(sobj)
            subobj_scores(ii) = sobj(so);
            ii = ii + 1;
        end
    end  
end
subobj_scores(ii:end) = [];
end