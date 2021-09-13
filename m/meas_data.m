function [facts,values] = meas_data(meas,atts,TALK)
call = ['defquery temp-query ?f <- (REQUIREMENTS::Measurement (Parameter "' meas '") '];
for i = 1:length(atts)
    call = [call ' ( ' atts{i} ' ?v' num2str(i) ') ' ];
end
call = [call ')'];

jess(call);
result = jess('run-query* temp-query');

facts = {};
values= {};
while result.next()
    facts = [facts {result.getObject('f')}];
    tmp = result.getObject('f').getFactId();
    if TALK,fprintf('Fact %d has ...',tmp);end
    these_vals = {};
    for i = 1:length(atts)
        these_vals = [these_vals {result.getString(['v' num2str(i)])}];
        if TALK,fprintf(' %s = %s ',atts{i},char(these_vals{end}));end
    end
    if TALK,fprintf('\n');end
    values = [values {these_vals}];
end

jess_remove_rule temp-query;
    
end