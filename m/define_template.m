
function define_template(name,module,desc,slots_txt)
%% define_template.m
% 
% This function defines a template named name, in module module, and slots 
% defined in a N x 2 cell array of strings txt  with the following structure:
% txt(:,1) contains the type of slot (slot/multislot)
% txt(:,2) contains the name of the slot
%
% Daniel Selva <dselva@mit.edu> 08/09/2012
%
r = global_jess_engine();
slot_types = slots_txt(:,1);
slot_names = slots_txt(:,2);
index_slots = strcmp(slot_types,'slot');
index_multislots = strcmp(slot_types,'multislot');
slots = slot_names(index_slots);
multislots = slot_names(index_multislots);

call = [' (deftemplate ' module '::' name ' "' desc '"' ];

for j = 1:length(slots)
    call = [call ' (slot ' slots{j} ' ) '];
end

for j = 1:length(multislots)
    call = [call ' (multislot ' multislots{j} ' ) '];
end

call = [call ') '];
r.eval(call);

% fid = fopen([ pwd '\clp\more_templates.clp' ],'a');
% fprintf(fid,call);
% fclose(fid);
end