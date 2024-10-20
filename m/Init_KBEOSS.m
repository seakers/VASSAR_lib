function [r,obj_C1,obj_C2,obj_C3,obj_C4,obj_C5] = Init_KBEOSS()
%% script_init_KBEOSS.m
%% Preliminaries
% Add path
javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\dist\EOLanguage.jar')
javaaddpath('C:\Documents and Settings\Dani\My Documents\software\Jess71p2\lib\jess.jar');
javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\build\classes\');

%% Import measurement attributes (global variables)
% Read xls Measurement attribute definitions
[num,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\AttributeSet','Measurement');


% Create attributeList: attribute hashtable associating characteristics to keys
% Example of use: 
% int index = GlobalVariables.attributeList.get(charac);
attribs_to_keys = CreateAttributeListHashtable(num,txt);

% Create attributeKeys: attribute hashtable associating keys to characteristics
% Example of use: 
% String charact = GlobalVariables.attributeKeys.get(new Integer(i)).toString();
keys_to_attribs = CreateAttributeKeysHashMap(num,txt);

% Create attributeTypes: attribute hashtable associating types to characteristics
% Example of use: 
% String typ = GlobalVariables.attributeTypes.get(charact).toString();
attribs_to_types = CreateAttributeTypesHashMap(num,txt);


% Create hashmap associating characteristic to specific EOAttributes
% Example of use: 
% EOAttribute att = (EOAttribute) GlobalVariables.attributeSet.get(charact);

attribSet = CreateAttributeSetHashMap(num,txt);


% load Global Variables
GlobalVariables.defineMeasurement(attribs_to_keys,keys_to_attribs,attribs_to_types,attribSet);

%% Init Jess
import jess.*
r = jess.Rete();
r.eval('(watch all)');

%% Import global variables for objective definition
[num,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\ObjectiveDefinition','GlobalVariables');
pref = '(defglobal ';
mid = ' = ';
suff = ')';
for i = 1:length(txt)
    call = [pref txt{i} mid num2str(num(i)) suff];
    r.eval(call);
end


%% Create Measuremenet template
call = '(deftemplate Measurement "A measurement"';
for i = 1:keys_to_attribs.size
    attrib = keys_to_attribs.get(java.lang.Integer(i-1));
%     attrib = regexprep(attrib, '/', '-');
%     attribs_to_keys.put(java.lang.Integer(i),attrib);
    call = [call ' (slot ' attrib ')'];
end
call = [call ')'];
r.eval(call);

%% User functions
r.eval('(deffunction update-objective-variable (?obj ?new-value) “Update the value of the global variable with the new value only if it is better” (bind ?obj (max ?obj ?new-value)))');
r.addUserfunction(SameOrBetter);

%% Import rules for subobjectives (from excel?)
r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate1.clp")');
r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate2.clp")');
r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate3.clp")');
r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate4.clp")');
r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate5.clp")');

%% Facts: Import instrument characteristics
% for each instrument, assert all the measureements in the measurements
% array attribute using deffacts

% r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\facts_test_measurements.clp")');

[~,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\EOLanguage\CaseStudies.xlsx','Instruments');
fid = - 1;
filename = [];
filepath = [];
for i = 2:125
    line = txt(i,:);
    instr_name = line{2};
        
    if (~isempty(instr_name)) % new instrument
        % close previous file if any
        current_instr = instr_name;
        if fid > 0
            fprintf(fid,')');
            fclose(fid);
            command = ['(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\' filename '")'];
            r.eval(command);
        end
        filepath = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\';
        filename = ['facts_' current_instr '.clp'];

        fid = fopen([filepath filename], 'w');
        % Write header
        fprintf(fid, ['(deffacts measurements-' instr_name '\n']);

    end
    % Write one line
    param = line{3};
    coverage = line{4};
    hsr = line{5};
    tr = line{6};
    ss = line{7};
    acc = line{8};
    pol = line{9};
    sw = line{10};
    cal = line{11};
    rad = line{12};
    
    fprintf(fid,['(Measurement (Parameter "' param '") (LEO-capability ' coverage ') (Horizontal-Spatial-Resolution ' hsr ') (Temporal-resolution ' tr ') (Spectral-sampling ' ss ') (Accuracy ' acc ') (Polarimetry ' pol ') (Swath ' sw ') (On-board-calibration ' cal ') (Radiometric-accuracy ' rad '))\n']);

end
fclose(fid);

%% Run the Jess engine.
    % This fires update of all subobjective global variables (rules group 2)
r.setResetGlobals(false);    
r.reset;
r.run;

%% Get values of all subobjective variables
% obj_C1 = r.eval('?*obj-clim1*').floatValue(r.getGlobalContext());
% obj_C2 = r.eval('?*obj-clim2*').floatValue(r.getGlobalContext());
% obj_C3 = r.eval('?*obj-clim3*').floatValue(r.getGlobalContext());
% obj_C4 = r.eval('?*obj-clim4*').floatValue(r.getGlobalContext());
% obj_C5 = r.eval('?*obj-clim5*').floatValue(r.getGlobalContext());
[obj_C1,obj_C2,obj_C3,obj_C4,obj_C5] = get_climate_objectives_values(r);
return
