function subobj_weights_map = subobj_weight_map()
global params
w = params.subobj_weights;
np = length(w);
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
subobj_weights_map = java.util.HashMap;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = params.subobj_weights{p}{o};
        for so = 1:length(sobj)
            subobj_name = [params.panel_names{p} num2str(o) '-' num2str(so)];
            subobj_weight = params.panel_weights(p)*params.obj_weights{p}(o)*sobj(so);
            subobj_weights_map.put(subobj_name,subobj_weight);
        end
    end  
end
end