function [facts,values] = my_jess_query_multi(varargin)
fact = varargin{1};
getme = varargin{2};
if nargin>2
    TALK = varargin{3};
else
    TALK = true;
end
    jess(['defquery temp-query ' ...
                '?f <- (' fact '( ' getme ' $?v)'  ')']);
            
    result = jess('run-query* temp-query');
    
    facts = {};
    values= {};
    while result.next()
        facts = [facts {result.getObject('f')}];
        values = [values {StringArraytoStringWithSpaces(jess_value(result.getObject('f').getSlotValue(getme)))}];
        tmp = result.getObject('f').getFactId();
        if TALK,fprintf('Fact %d has %s = %s\n',tmp,getme,char(values{end}));end
    end
    
    jess_remove_rule temp-query;
end