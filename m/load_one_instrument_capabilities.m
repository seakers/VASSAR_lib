function load_one_instrument_capabilities(instr)
global params
r = global_jess_engine();

instrument_list = params.instrument_list;
% i = find(strcmp(instrument_list,instr),1);
meas = java.util.ArrayList;
subobj = java.util.ArrayList;
obj = java.util.ArrayList;
pan = java.util.ArrayList;

fprintf('Instrument %s...\n',instr);
[~,txt]= xlsread(params.capability_rules_xls,instr);
num_measurements = size(txt,1);

call = ['(defrule CAPABILITIES::' instr '-measurements  ' ...
'"Define measurement capabilities of instrument ' instr '" ' ...
'?this <- (CAPABILITIES::Manifested-instrument  (Name ' instr ') (Id ?id) (flies-in ?miss) (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) )  ' ...
' => ' ...
' '];
list_of_measurements = [];

for ii = 1:num_measurements
    call = [call sprintf('(assert (REQUIREMENTS::Measurement')];
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
        call = [call sprintf([' (' att_value_pair ') '])];
    end
    call = [call sprintf([' (taken-by ' instr ') '])];
    call = [call sprintf(' (flies-in ?miss) ')];
    call = [call sprintf(' (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) ')];
    call = [call sprintf([' (Id ' instr num2str(ii) ') (Instrument ' instr ' ) '])];
    call = [call sprintf('))\n')];
    list_of_measurements = [list_of_measurements ' ' instr num2str(ii) ' '];
end
call = [call sprintf(['(assert (SYNERGIES::cross-registered (measurements ' list_of_measurements ' ) (degree-of-cross-registration ' ' instrument) (platform ?id  )))'])];
call = [call sprintf(['(modify ?this (measurement-ids ' list_of_measurements '))'])];
call = [call sprintf(')\n')];

r.eval(call);
    
end
