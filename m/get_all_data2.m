function [facts,values] = get_all_data2(templ,atts,multi,TALK)
call = ['defquery temp-query ?f <- (' templ ' '];
for i = 1:length(atts)
    if strcmp(multi{i},'single')
        call = [call ' ( ' atts{i} ' ?v' num2str(i) ') ' ];
    else
        call = [call ' ( ' atts{i} ' $?v' num2str(i) ') ' ];
    end
end
call = [call ')'];

jess(call);
result = jess('run-query* temp-query');

facts = {};
values= {};
n = 1;
while result.next()
    facts = [facts {result.getObject('f')}];
    tmp = result.getObject('f').getFactId();
    if TALK,fprintf('Fact %d has ...',tmp);end
    these_vals = {};
    for i = 1:length(atts)
        if strncmp(multi{i},'single-char',8)
            these_vals = [these_vals {result.getString(['v' num2str(i)])}];
        elseif strncmp(multi{i},'single-num',8)
            these_vals = [these_vals {result.getDouble(['v' num2str(i)])}];
        elseif strcmp(multi{i},'multi-char')
            these_vals =  [these_vals {StringArraytoStringWithSpaces(jess_value(result.get(['v' num2str(i)])))}];
        elseif strcmp(multi{i},'multi-num')
            these_vals =  [these_vals {cell2mat(jess_value(result.get(['v' num2str(i)])))}];
        else
            error('Type of slot not supported, choose single, multi-char or multi-num');
        end
        
        if TALK
            if strncmp(multi{i},'single-char',8)
                fprintf(' %s = %s ',atts{i},char(these_vals{end}));
            elseif strncmp(multi{i},'single-num',8)
                fprintf(' %s = %f ',atts{i},these_vals{end});
            else
                fprintf(' %s = %s ',atts{i},num2str(these_vals{end}));
            end
        end
    end
    if TALK,fprintf('\n');end
    values{n} = these_vals;n = n + 1;
end

jess_remove_rule temp-query;
    
end