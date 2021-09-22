function score_struct = RBES_find_subobj_by_names(names)
global params
% ex: naems = [WAE6-2, OZO1-3, OZO2-3, WAE6-1]
score_struct = params.subobj_weights;
np = params.npanels;
no_vec = cell2mat(cellfun(@length,params.obj_weights,'UniformOutput',false));

for p = 1:np
    for o = 1:no_vec(p)
        sobj = score_struct{p}{o};
        for so = 1:length(sobj)
            score_struct{p}{o}(so) = 0;
        end
    end  
end

iter = names.iterator;
while(iter.hasNext())
    subobj = iter.next();
    pan = regexp(char(subobj),'(?<panel>\D+)(?<obj>\d+)-(?<subobj>\d+)','names');
    p = find(strcmp(params.panel_names,pan.panel));
    o = str2num(pan.obj);
    so = str2num(pan.subobj);
    score_struct{p}{o}(so) = 1;
end
end
