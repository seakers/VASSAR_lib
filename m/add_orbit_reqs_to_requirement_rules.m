function [] = add_orbit_reqs_to_requirement_rules()

%% Read requirements to variables
[~,~,raw] = xlsread('./xls/Decadal Objective Rule Definition.xlsx','Requirement rules');
subobjs = raw(2:end,3);
rule_types = raw(2:end,6);
values = cell2mat(raw(2:end,7));
descriptions = raw(2:end,8);
measurements = raw(2:end,9);
attribs = raw(2:end,10:end);
nrules = size(raw,1);
nattribs = size(raw,2)-9;
new_subobjs = strcmp(rule_types,'nominal');%boolean indexes of new subobjectives (add +1 for indexes in raw cell)
nsubobjs = sum(new_subobjs);

%% Loop to add orbit requirements
pos = find(new_subobjs);
for i = 1:nsubobjs
    line = raw(pos(i)+1,:);
end

%% Write xls file
end

function new_raw = insert_line(raw,line)
end