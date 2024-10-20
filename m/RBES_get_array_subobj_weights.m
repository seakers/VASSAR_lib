function subobj_weights = RBES_get_array_subobj_weights()
global params
w = params.subobj_weights;
np = length(w);
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
subobj_weights = zeros(1000,1);
ii = 1;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = params.subobj_weights{p}{o};
        for so = 1:length(sobj)
            subobj_weights(ii) = params.panel_weights(p)*params.obj_weights{p}(o)*sobj(so);
            ii = ii + 1;
        end
    end  
end
subobj_weights(ii:end) = [];
end