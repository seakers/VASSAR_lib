function score = RBES_get_score_from_subobj_struct(subobj_struct)
global params
w = params.subobj_weights;
np = length(w);
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
score = 0;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = params.subobj_weights{p}{o};
        for so = 1:length(sobj)
            score  = score + params.panel_weights(p)*params.obj_weights{p}(o)*sobj(so)*subobj_struct{p}{o}(so);
        end
    end  
end
end
