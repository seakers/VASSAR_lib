function r = load_rules_from_excel(r,filename,sheet)
% load_rules_from_excel('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Weather');
[num,txt]= xlsread(filename,sheet);

pref = '(defrule subobjective-';
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
for i = 2:size(txt,1)
    line = txt(i,:);
    obj = line{1};
    if(~strcmp(obj,curr_obj))
        var_name = ['obj' dash obj];
        call = ['(defglobal ?*' var_name '* = ' num2str(0) ')'];
        r.eval(call);
        curr_obj = obj;
    end
    subobj = line{3};
    if(~strcmp(subobj,curr_subobj))
        var_name = ['subobj' dash subobj];
        call = ['(defglobal ?*' var_name '* = ' num2str(0) ')'];
        r.eval(call);
        curr_subobj = subobj;
        
    end
    type = line{6};
    value = num(i-1,4);

    desc = line{8};
    param = line{9};

    call = [pref subobj dash type space desc space open_par 'Measurement ' open_par 'Parameter ' param close_par space];% (defrule subobjective-WE1-1-full "Conditions for full satisfaction of subobjective WE1-1" (Measurement (Parameter "1.4.1 atmospheric wind speed")
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
            calls_for_later{ntests} = ['(test (SameOrBetter ' att space new_var_name space val '))'];
        elseif(strncmp(header,'ContainsRegion',14))
            ntests = ntests  + 1;
            [att,val] = strtok(remain,' ');
            new_var_name = ['?x' num2str(ntests)];%?hsr&:(neq ?hsr nil)
            tmp = [att space new_var_name '&:(neq ' new_var_name ' nil)'];
            add_to_call = [open_par tmp close_par];
            call = [call space add_to_call];
            calls_for_later{ntests} = ['(test (ContainsRegion ' new_var_name space val '))'];
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

    call = [call arrow space space];

    var_name = ['?*subobj-' subobj '*'];
    add_to_call = ['(bind' space var_name ' (max ' var_name space num2str(value) ')))'];
    call = [call add_to_call];
%     save call call;
    r.eval(call);

%     i = i + 1;% new rule
end
return
