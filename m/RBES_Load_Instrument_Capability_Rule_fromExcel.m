%% RBES_Load_Instrument_Capability_Rule_fromExcel.m
% Unused as of Dec 3rd 2011
% Daniel Selva
function [meas,subobj,obj,pan] = RBES_Load_Instrument_Capability_Rule_fromExcel(filename,sheet)
global params
r = global_jess_engine();

% This function creates a clp file for an instrument so that if that
% instrument is asserted by name then all its measurements are asserted.
meas = java.util.ArrayList;
subobj = java.util.ArrayList;
obj = java.util.ArrayList;
pan = java.util.ArrayList;

%% Import data to create fact file
[~,txt]= xlsread(filename,sheet);
num_measurements = size(txt,1);
% fid = fopen([sheet '.clp'],'w');
% fid = fopen('fact_file.clp','w');
fid = [];
list_of_measurements = [];
fid = ['(defrule CAPABILITIES::' sheet '-measurements \n' ...
    '"Define measurement capabilities of instrument ' sheet '"\n' ...
    '?this <- (CAPABILITIES::Manifested-instrument  (Name ' sheet ') (Id ?id) (flies-in ?miss) (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) )\n' ...
    ' => ' ...
    '\n'];
for ii = 1:num_measurements
    fid = [fid sprintf(fid,'(assert (REQUIREMENTS::Measurement')];
    line = txt(ii,:);
    for j = 2:length(line)
        att_value_pair = line{j};
        if j == 2
            tmp = strfind(att_value_pair,' ');          
            parameter = att_value_pair(tmp(1)+1:end);
            meas.add(parameter);
            list_subobjs = params.measurements_to_subobjectives.get(parameter);
            if ~isempty(list_subobjs)
                list_subobjs2 = list_subobjs.iterator;
                while(list_subobjs2.hasNext)
                    tmp = list_subobjs2.next();
                    subob = tmp(10:end-1);
                    if ~subobj.contains(subob)
                        subobj.add(subob);
                    end
                    
                    tmp = strfind(subob,'-');
                    ob = subob(1:tmp-1);
                    
                    if ~obj.contains(ob)
                        obj.add(ob);
                    end
                    
                    tmp2 = regexp(ob,'(?<pan>\D+)(?<obj>\d+)','names');
                    pa = tmp2.pan;
                    
                    if ~pan.contains(pa)
                        pan.add(pa);
                    end
                    
                end
            end
        end
        fid = [fid sprintf(fid,[' (' att_value_pair ') '])];
    end
    fid = [fid sprintf(fid,[' (taken-by ' sheet ') '])];
    fid = [fid sprintf(fid,' (flies-in ?miss) ')];
    fid = [fid sprintf(fid,' (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) ')];
    fid = [fid sprintf(fid,[' (Id ' sheet num2str(ii) ') (Instrument ' sheet ' ) '])];
    fid = [fid sprintf(fid,'))\n')];
    list_of_measurements = [list_of_measurements ' ' sheet num2str(ii) ' '];
end
fid = [fid sprintf(fid,['(assert (SYNERGIES::cross-registered (measurements ' list_of_measurements ' ) (degree-of-cross-registration ' ' instrument) (platform ?id  )))'])];
fid = [fid sprintf(fid,['(modify ?this (measurement-ids ' list_of_measurements '))'])];
fid = [fid sprintf(fid,')\n')];
% fclose(fid);
% 
% r.reset;
r.eval(fid);

return
