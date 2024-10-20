function [value] = jess_attr(attr, fact)
% GET_JESS, attr: string, fact: jess.Fact representing the system

try % prop being a slot of the fact
        
    v = fact.getSlotValue(attr); % throws jess.JessException
    value = jess_value(v);
        
catch err 
    if isempty(findstr(err.message, ['No slot ' attr ' in deftemplate ']))
        rethrow(err);
    else
    try % prop being an unordered fact header with an associated query
        % (see define_property.m)

        % don't ask me why this code produces 0 query results and the
        % next one works fine (although it's apparently a lot slower)
%             result = j.runQueryStar(...
%                 ['query-' prop],...
%                 jess.ValueVector().add(fact));
        result = jess({'run-query*' ['query-' attr] ...
                            '(fact-id' int64(fact.getFactId()) ')'});
        if result.next()
            value = matlab_value(result.get('value'));
        else
            throw(MException('MATLAB:Java:GenericException',...
                'No query results'));
        end

    catch err
        if isempty(findstr(err.message,'No such query: '))
            rethrow(err);
        else
            error 'No slot nor query with that name found.'
        end
    end
end
end