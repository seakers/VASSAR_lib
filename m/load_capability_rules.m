function load_capability_rules (Excel)
%% load_capability_rules.m
% This function reads the instrument capability rules in the excel file and
% creates a Hashmap that contains the pool of available instruments for
% this cae study. Note that the instruments are not yet assigned an orbit.

global params
r = global_jess_engine();

r.eval(['(bind ?capability_rules_clp "' params.capability_rules_clp '")']);
r.eval('(batch ?capability_rules_clp)');

import java.util.HashMap
instrument_list1 = params.instrument_list;
if isfield(params,'packaging_instrument_list') && isfield(params,'scheduling_instrument_list')
    instrument_list2 = params.packaging_instrument_list;
    instrument_list3 = params.scheduling_instrument_list;
    instrument_list = unique([instrument_list1' instrument_list2 instrument_list3])';
else
    instrument_list = instrument_list1;
end
    
n = length(instrument_list);
params.instrument_pool = HashMap;
params.instruments_to_measurements = HashMap;
params.instruments_to_subobjectives = HashMap;
params.instruments_to_objectives = HashMap;
params.instruments_to_panels = HashMap;

% Excel = actxserver ('Excel.Application'); 
% File=[ 'C:\Users\dani\Documents\My Dropbox\RBES' params.capability_rules_xls]; 
% if ~exist(File,'file') 
% ExcelWorkbook = Excel.workbooks.Add; 
% ExcelWorkbook.SaveAs(File,1); 
% ExcelWorkbook.Close(false); 
% end 
% invoke(Excel.Workbooks,'Open',File);

for i = 1:n
    meas = java.util.ArrayList;
    subobj = java.util.ArrayList;
    obj = java.util.ArrayList;
    pan = java.util.ArrayList;
    
    fprintf('Instrument %s...\n',instrument_list{i});
    [~,txt]= xlsread1(params.capability_rules_xls,instrument_list{i});
    num_measurements = size(txt,1);
    
    % Rule that initiates all can-take-measurements to yes
    call = ['(defrule MANIFEST::' instrument_list{i} '-init-can-measure ' ...
    '(declare (salience -20)) ' ...
    '?this <- (CAPABILITIES::Manifested-instrument  (Name ?ins&' instrument_list{i} ') (Id ?id) (flies-in ?miss) (Intent ?int) (Spectral-region ?sr) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-inclination ?inc) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) (Illumination ?il))  ' ...
    ' (not (CAPABILITIES::can-measure (instrument ?ins) (can-take-measurements no)))' ...
    ' => ' ...
    ' (assert (CAPABILITIES::can-measure (instrument ?ins) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-inclination ?inc) (data-rate-duty-cycle# nil) (power-duty-cycle# nil)(orbit-RAAN ?raan) (in-orbit (str-cat ?typ "-" ?h "-" ?inc "-" ?raan)) (can-take-measurements yes) (reason "by default")))' ...
    ' )'];
    r.eval(call);
    
    call = ['(defrule CAPABILITIES::' instrument_list{i} '-measurements  ' ...
    '"Define measurement capabilities of instrument ' instrument_list{i} '" ' ...
    '?this <- (CAPABILITIES::Manifested-instrument  (Name ?ins&' instrument_list{i} ') (Id ?id) (flies-in ?miss) (Intent ?int) (Spectral-region ?sr) (orbit-type ?typ) (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) (Illumination ?il))  ' ...
    ' (CAPABILITIES::can-measure (instrument ?ins) (can-take-measurements yes) (data-rate-duty-cycle# ?dc-d) (power-duty-cycle# ?dc-p)) ' ...
    ' => ' ...
    ' (bind ?*science-multiplier* (min 1 ?dc-d ?dc-p)) ' ...
    ' (assert (CAPABILITIES::resource-limitations (data-rate-duty-cycle# ?dc-d) (power-duty-cycle# ?dc-p))) ' ...
    ' '];
    list_of_measurements = [];

    for ii = 1:num_measurements
        call = [call sprintf('(assert (REQUIREMENTS::Measurement (data-quantity-multiplier# (min 1 ?dc-d ?dc-p)) ')];
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
        call = [call sprintf([' (taken-by ' instrument_list{i} ') '])];
        call = [call sprintf(' (flies-in ?miss) ')];
        call = [call sprintf(' (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) ')];
        call = [call sprintf([' (Id ' instrument_list{i} num2str(ii) ') (Instrument ' instrument_list{i} ' ) '])];
        call = [call sprintf('))\n')];
        list_of_measurements = [list_of_measurements ' ' instrument_list{i} num2str(ii) ' '];
    end
    call = [call sprintf(['(assert (SYNERGIES::cross-registered (measurements ' list_of_measurements ' ) (degree-of-cross-registration ' ' instrument) (platform ?id  )))'])];
    call = [call sprintf(['(modify ?this (measurement-ids ' list_of_measurements '))'])];
    call = [call sprintf(')\n')];
    
    r.eval(call);
    
    params.instruments_to_measurements.put(instrument_list{i},meas);
    params.instruments_to_subobjectives.put(instrument_list{i},subobj);
    params.instruments_to_objectives.put(instrument_list{i},obj);
    params.instruments_to_panels.put(instrument_list{i},pan);

    instr = Instrument(instrument_list{i});
    params.instrument_pool.put(instrument_list{i},instr);
    
end

% Excel.ActiveWorkbook.Save; 
% Excel.Quit 
% Excel.delete 
% clear Excel

params.measurements_to_instruments = getInverseHashMap(params.instruments_to_measurements);
params.subobjectives_to_instruments = getInverseHashMap(params.instruments_to_measurements);
params.objectives_to_instruments = getInverseHashMap(params.instruments_to_objectives);
params.panels_to_instruments = getInverseHashMap(params.instruments_to_panels);
return

