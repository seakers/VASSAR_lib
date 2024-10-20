function [ids,satisfactions] = get_satisfaction(type,variables)
    switch type
        case 'architecture'
            query_name = 'SATISFACTION::get-architecture-benefit';
            ID = false;
        case 'stakeholder'
            if strcmp(variables,'all')
                query_name = 'SATISFACTION::get-stakeholder-satisfaction';
                variables = '';
            else
                query_name = 'SATISFACTION::search-stakeholder-satisfaction';
            end
            
            ID = true;
        case 'objective'
            query_name = 'SATISFACTION::get-objective-satisfaction';
            ID = true;
    end
            
    result = jess(['run-query* ' query_name ' ' variables]);
    
    ids = {};
    satisfactions= {};
    while result.next()
        if ID
            ids = [ids {result.getString('id')}];
        else
            ids = [];
        end
        satisfactions = [satisfactions {result.getDouble('sat')}];
    end
end