function [facts] = jess_query(varargin)
    jess(['defquery temp-query ' ...
                '?f <- (' varargin{:} ')']);
            
    result = jess('run-query* temp-query');
    
    facts = {};
    while result.next()
        facts = [facts {result.getObject('f')}];
    end
    
    jess_remove_rule temp-query;
end