function score = RBES_Evaluate_subobjective(subobj,recompute)
global params
r = global_jess_engine();
if recompute
    RBES_Evaluate_Manifest;
end
% compute p, o, so
for p =1:params.npanels
    for o = 1:params.num_objectives_per_panel(p)
        for so = 1:length(params.subobjectives{p}{o})
            str = java.lang.String(params.subobjectives{p}{o}{so});
            if str.contains(java.lang.String(subobj))
                pp = p;oo = o;ssoo = so;
                var_name = ['?*' params.subobjectives{p}{o}{so} '*'];
                tmp = r.eval(var_name).floatValue(r.getGlobalContext());
                break;
            end
        end
    end
end 

score = tmp*params.panel_weights(pp)*params.obj_weights{pp}(oo)*params.subobj_weights{pp}{oo}(ssoo);
end