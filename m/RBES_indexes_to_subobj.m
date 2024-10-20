function subobj = RBES_indexes_to_subobj(p,o,so)
global params
% tmp = regexp(subobj,'(?<pan>\D*)(?<obj>\d*)-(?<sub>\d*)','names');
pan = params.panel_names(p);
obj = num2str(o);
subob = num2str(so);
subobj = strcat(pan,obj,'-',subob);
end