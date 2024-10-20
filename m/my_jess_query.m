function [facts,values] = my_jess_query(varargin)
fact = varargin{1};
getme = varargin{2};
jess defadvice before (create$ >= <= < >) (foreach ?xxx $?argv (if (eq ?xxx nil) then (return FALSE)));
if nargin>2
    TALK = varargin{3};
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
        values = [values {result.getString('v')}];
        tmp = result.getObject('f').getFactId();
        if TALK,fprintf('Fact %d has %s = %s\n',tmp,getme,char(values{end}));end
    end
    
    jess_remove_rule temp-query;
    jess undefadvice (create$ >= <= < > sqrt + * **);
end