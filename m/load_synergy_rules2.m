function load_synergy_rules2
%% load_synergy_rules2.m
global params
r = global_jess_engine();

%% One of a kind rules (new measurements)
r.eval(['(bind ?synergy_clp_file "' params.synergy_rules_clp '")']);
r.eval('(batch ?synergy_clp_file)');

% %% Recurring rules: Improve measurements
% [num,txt,raw] = xlsread(params.synergy_rules_xls,'Improve Measurements');
% for i = 2:size(raw,1)
%     line = raw(i,:);
%     m1 = line{1};% is improved by m2
%     m2 = line{2};% improves m1
%     deg_of_crossreg = line{3};
%     acc_req_m2 = line{4};
%     improvement = line{5};
%     
%     call = ['(defrule SYNERGIES::Improve-Measurement' num2str(i) ' ' ...
%         '(declare (salience 5))' ...
%         '?m1 <- (REQUIREMENTS::Measurement (Parameter '  m1 ') ' ...
%         '(Accuracy ?acc1&~nil) (Id ?id1))' ...
%         '(REQUIREMENTS::Measurement (Parameter ' m2 ') ' ...
%         '(Accuracy ?acc2) (Id ?id2))' ...
%         '(SYNERGIES::cross-registered (measurements $?m))' ...
%         '(test (member ?id1 $?m))' ...
%         '(test (member ?id2 $?m))' ...
%         ' => ' ...
%         '(modify ?m1 (Accuracy (eval (Improve Accuracy ?acc1))))' ...
%         ')'];
%     r.eval(call);
% end

%% Requirement rules for synergies
[num,txt]= xlsread(params.requirement_rules_xls,'Requirement rules');
% meas2panels = java.util.HashMap;
% panels2meas = java.util.HashMap;

pref = '(defrule SYNERGIES::subobjective-';
space = ' ';
arrow = ' => ';
% finish = false;
open_par = '(';
close_par = ')';
dash = '-';
curr_subobj = '';
curr_obj = '';
% nobj = 0;
% i = 2;
params.obj_names = cell(25,1);% this pre-dimensioning is not actually used
params.subobj_names = cell(25,25);% this pre-dimensioning is not actually used
params.measurements_to_subobjectives = java.util.HashMap;
params.measurements_to_objectives = java.util.HashMap;
params.measurements_to_panels = java.util.HashMap;
params.objectives = java.util.ArrayList;
nobj = 0;
for i = 2:size(txt,1)
    line = txt(i,:);
    obj = line{1};
    explan = line{2};
    if(~strcmp(obj,curr_obj))
        nobj = nobj + 1;
        nsubobj = 0;
        var_name = ['obj' dash obj];
        params.obj_names{nobj} = var_name;
        params.objectives.add(obj);
        call = ['(defglobal ?*' var_name '* = ' num2str(0) ')'];
        r.eval(call);
        curr_obj = obj;
    end
    subobj = line{3};
    if(~strcmp(subobj,curr_subobj))
        nsubobj = nsubobj + 1;
        var_name = ['subobj' dash subobj];
        params.subobj_names{nobj,nsubobj} = var_name;
        call = ['(defglobal ?*' var_name '* = ' num2str(0) ')'];
        r.eval(call);
        curr_subobj = subobj;
        
    end
    type = line{6};
    value = num(i-1,4);

    desc = line{8};
    param = line{9};
    tmp =  ['?*subobj-' subobj '*'];
    if params.measurements_to_subobjectives.containsKey(param)
        list = params.measurements_to_subobjectives.get(param);
        if(~list.contains(tmp))
            list.add(tmp);
            params.measurements_to_subobjectives.put(param,list);
        end       
    else
        list = java.util.ArrayList;
        list.add(tmp);
        params.measurements_to_subobjectives.put(param,list);
    end
    
    if params.measurements_to_objectives.containsKey(param)
        list = params.measurements_to_objectives.get(param);
        if(~list.contains(obj))
            list.add(obj);
            params.measurements_to_objectives.put(param,list);
        end       
    else
        list = java.util.ArrayList;
        list.add(obj);
        params.measurements_to_objectives.put(param,list);
    end
%     [pan,~,~] = RBES_subobj_to_indexes(subobj);
    pan = obj(1:3);
    if params.measurements_to_panels.containsKey(param)
        list = params.measurements_to_panels.get(param);
        if(~list.contains(pan))
            list.add(pan);
            params.measurements_to_panels.put(param,list);
        end       
    else
        list = java.util.ArrayList;
        list.add(pan);
        params.measurements_to_panels.put(param,list);
    end

    call = [pref subobj dash type space desc space open_par 'REQUIREMENTS::Measurement (data-quantity-multiplier# ?mult) ' open_par 'Parameter ' param close_par space open_par 'taken-by ?who' close_par space];% ( subobjective-WE1-1-full "Conditions for full satisfaction of subobjective WE1-1" (Measurement (Parameter "1.4.1 atmospheric wind speed")
%     curr_subobj = subobj;
    more_attributes = true;
    j = 10;
    ntests = 0;
    calls_for_later = [];
    while more_attributes
        attrib = line{j};
        [header,remain] = strtok(attrib,' ');
        if(strcmp(attrib,''))
            call = [call close_par];
            more_attributes = false;
        elseif(strncmp(header,'SameOrBetter',12))
            ntests = ntests  + 1;
            [att,val] = strtok(remain,' ');
            new_var_name = ['?x' num2str(ntests)];%?hsr&:(neq ?hsr nil)
            tmp = [att space new_var_name '&:(neq ' new_var_name ' nil)'];
            add_to_call = [open_par tmp close_par];
            call = [call space add_to_call];
            calls_for_later{ntests} = ['(test (>= (SameOrBetter ' att space new_var_name space val ') 0))'];
        elseif(strncmp(header,'ContainsRegion',14))
            ntests = ntests  + 1;
            [att,val] = strtok(remain,' ');
            new_var_name = ['?x' num2str(ntests)];%?hsr&:(neq ?hsr nil)
            tmp = [att space new_var_name '&:(neq ' new_var_name ' nil)'];
            add_to_call = [open_par tmp close_par];
            call = [call space add_to_call];
            calls_for_later{ntests} = ['(test (ContainsRegion ' new_var_name space val '))'];
        elseif(strncmp(header,'ContainsBands',14))
            ntests = ntests  + 1;
            % remain contains a list of all the desired bands
            new_var_name = ['?x' num2str(ntests)];%?hsr&:(neq ?hsr nil)
            tmp = ['spectral-bands' space '$' new_var_name];
            add_to_call = [open_par tmp close_par];
            call = [call space add_to_call];
            calls_for_later{ntests} = ['(test (ContainsBands (create$ '  remain ')' space '$' new_var_name '))'];
        
        else
            add_to_call = [open_par attrib close_par];
            call = [call space add_to_call];
        end
        j = j + 1;
    end
    call = [call space space];
    for k = 1:ntests
        call = [call space calls_for_later{k}];
    end
    % %%%%%%%%%%%%%%%%%%%%%%%%
    % insert not already fully satisfied
    add_to_call = ['(not (REASONING::fully-satisfied (subobjective ' subobj '))) '];
    call = [call space add_to_call];
    % %%%%%%%%%%%%%%%%%%%%%%%% 
    
    
    call = [call arrow space space];
    var_name = ['?*subobj-' subobj '*'];
    
    
    if(~strncmp(type,'nominal',3))
        add_to_call = ['(assert (REASONING::partially-satisfied (subobjective ' subobj  ...
        ') (parameter ' param ') (objective "' explan '") (taken-by ?who ) (attribute ' desc ')))' ];
        call = [call add_to_call];  
    else
        add_to_call = ['(assert (REASONING::fully-satisfied (subobjective ' subobj ...
        ') (parameter ' param ') (objective "' explan '") (taken-by ?who )))' ];
        call = [call add_to_call];
    end
    
    add_to_call = ['(bind' space var_name ' (max ' var_name space open_par '* ' num2str(value) space '?mult' close_par ')))'];
    call = [call add_to_call];
%     save call call;
    r.eval(call);

%     i = i + 1;% new rule
end

%% synergy stopper rules
% add a rule for each measurement so that if facts have been asserted to 
% indicate full satisfaction of all the subobjectives related to this 
% measurement, no further synergy rules are applied to this measurement
it = params.measurements_to_subobjectives.entrySet.iterator;
while(it.hasNext)
    el = it.next;
    meas = el.getKey;
    subobjs = el.getValue.iterator;
    call = ['(defrule SYNERGIES::stop-improving-' meas(2:6) ' '];
    while(subobjs.hasNext)
        var = subobjs.next;
        addthis = [' (REASONING::fully-satisfied (subobjective ' var '))'];% if all the subobjectives are fully satisfied
        call = [call addthis];
    end
    call = [call ' => '];
    call = [call '(assert (REASONING::stop-improving (Measurement ' meas '))))'];
    r.eval(call);
end

    


params.subobjectives_to_measurements = getInverseHashMap(params.measurements_to_subobjectives);
params.objectives_to_measurements = getInverseHashMap(params.measurements_to_objectives);
params.panels_to_measurements = getInverseHashMap(params.measurements_to_panels);
return