function subobj_weights = RBES_get_struct_subobj_weights()
global params
w = params.subobj_weights;
np = length(w);
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
subobj_weights = params.subobj_weights;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = params.subobj_weights{p}{o};
        for so = 1:length(sobj)
            subobj_weights{p}{o}(so) = params.panel_weights(p)*params.obj_weights{p}(o)*sobj(so);
        end
    end  
end
end