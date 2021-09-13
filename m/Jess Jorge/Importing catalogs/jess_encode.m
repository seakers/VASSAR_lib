function [str] = jess_encode(v)
% JESS_ENCODE, v: jess.Value
% The inverse function of j.eval(str).

    mv = matlab_value(v);
    
    switch v.type()
        % this pain is derived from these documents:
        % http://www.jessrules.com/docs/71/api/jess/Value.html , and
        % http://www.jessrules.com/docs/71/api/jess/RU.html
        % Jess' author promises to solve it with a Factory;
        % check jess.ValueFactory .
        case jess.RU.FACT
            % 2^4
%             str = v.factValue(c);
            error('To encode facts, use (fact-id id).');
        case jess.RU.FLOAT
            % 2^5
            str = num2str(mv);
        case jess.RU.FUNCALL
            % 2^6
%             str = v.funcallValue(c);
            error('Don''t know how to encode a funcall.');
        case jess.RU.INTEGER
            % 2^2
            str = num2str(mv);
        case jess.RU.JAVA_OBJECT
            % 2^11
%             str = v.javaObjectValue(c);
            error('Can''t encode a Java object, unless it''s (engine).');
        case jess.RU.LIST
            % 2^9
            mv = cellmap(@jess_encode, mv);
            str = ['(list ' cat_with_spaces(mv) ')'];            
        case jess.RU.LONG
            % 2^16
            str = num2str(mv);
        case jess.RU.STRING
            % 2^1
            str = ['"' mv '"'];
        case jess.RU.SYMBOL
            % 2^0
            if islogical(mv)
                if mv
                    str = 'TRUE';
                else
                    str = 'FALSE';
                end
            elseif ischar(mv)
                str = mv;
            else
                error('Unknown symbol instance.');
            end
        case jess.RU.VARIABLE
            % 2^3
            str = mv;
        case jess.RU.NONE
            % 0
            str = [];
        case jess.RU.LAMBDA
            % 2^17
            value = v.functionValue(c);
            str = value.getName();
        otherwise
            % There doesn't seem to be methods corresponding to the type
            % values jess.RU.SLOT, jess.RU.MULTIVARIABLE, and
            % jess.RU.MULTISLOT.
            % These are just supersets:
            % jess.RU.LEXEME == jess.RU.SYMBOL | jess.RU.STRING
            % jess.RU.NUMBER == jess.RU.INTEGER | jess.RU.FLOAT |
            % jess.RU.LONG
            error(['Unknown Jess value type: ' num2str(v.type())]);
    end
end