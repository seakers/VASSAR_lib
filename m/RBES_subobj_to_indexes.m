function [p,o,so] = RBES_subobj_to_indexes(subobj)
global params
tmp = regexp(subobj,'(?<pan>\D*)(?<obj>\d*)-(?<sub>\d*)','names');
p = find(strcmp(params.panel_names,tmp.pan),1);
o = str2num(tmp.obj);
so = str2num(tmp.sub);

end