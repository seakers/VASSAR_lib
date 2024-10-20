function [names,full,partial,scores,missed] = RBES_find_objectives_satisfied(subobjective_scores,TALK)
global params
np  = params.npanels;
pnam = params.panel_names;
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));
names = java.util.ArrayList;
full = java.util.ArrayList;
partial = java.util.ArrayList;
missed = java.util.ArrayList;
scores = java.util.HashMap;
for p = 1:np
    for o = 1:no_vec(p)
        sobj = subobjective_scores{p}{o};
        for so = 1:length(sobj)
            str = [pnam{p} num2str(o) '-' num2str(so)];
            if sobj(so)>0
%                 fprintf('Subobjective %s (measurement %s) : %f\n',p,o,so,sobj(so));
                
                meas = RBES_subobj_to_meas(str);
                if TALK
                    fprintf('Subobjective %s (%s) : %f\n',str,char(meas),sobj(so));     
                end
                names.add(str);
                scores.put(str,sobj(so));
                if sobj(so) == 1
                    full.add(str);
                else
                    partial.add(str);
                end
            else
                missed.add(str);
            end
        end
    end  
end
end