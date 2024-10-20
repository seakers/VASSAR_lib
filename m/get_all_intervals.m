function [facts,values] = get_all_intervals(templ,slot,varargin)
fact = templ;
getme = slot;

if nargin>2
    TALK = varargin{1};
else
    TALK = true;
end
    jess(['defquery REASONING::temp-query ' ...
                '?f <- (' fact '( ' getme ' ?v)'  ')']);
            
    result = jess('run-query* temp-query');
    
    facts = {};
    values= {};
    while result.next()
        facts = [facts {result.getObject('f')}];
        values = [values {jess_value(result.get('v'))}];
        tmp = result.getObject('f').getFactId();
        if TALK,fprintf('Fact %d has %s = %s\n',tmp,getme,char(values{end}.toString));end
    end
    
    jess_remove_rule temp-query;
end