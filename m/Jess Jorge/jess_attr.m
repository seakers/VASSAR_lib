function [value] = jess_attr(attr, fact)
% GET_JESS, attr: string, fact: jess.Fact representing the system

    try % prop being a slot of the fact
        
        v = fact.getSlotValue(attr); % throws jess.JessException
        value = jess_value(v);
        
    catch err        
        try % prop being an unordered fact header with an associated query
            % (see define_property.m)

            % don't ask me why this code produces 0 query results and the
            % next one works fine (although it's apparently a lot slower)
%             result = j.runQueryStar(...
%                 ['query-' prop],...
%                 jess.ValueVector().add(fact));
            result = jess([...
                        'run-query* query-' attr ' '...
                            '(fact-id ' int2str(fact.getFactId()) ')'...
                        ]);
            if result.next()
                value = jess_value(result.get('value'));
            else
                throw(MException('MATLAB:Java:GenericException',...
                    'No query results'));
            end
            
        catch err2
            disp(err2.message);
            rethrow(err);
        end
    end
end