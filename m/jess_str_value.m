function [value] = jess_str_value(v)
% JESS_VALUE, v: jess.Value
% Transforms the return value of a call to jess.Rete.eval (a jess.Value
% object) into the equivalent Matlab value.

    j = global_jess_engine();
    c = j.getGlobalContext();
    
    switch v.type()
        % this pain is derived from these documents:
        % http://www.jessrules.com/docs/71/api/jess/Value.html , and
        % http://www.jessrules.com/docs/71/api/jess/RU.html
        % Jess' author promises to solve it with a Factory;
        % check jess.ValueFactory .
        case jess.RU.FLOAT
            % 2^5
            value = num2str(v.floatValue(c));
        case jess.RU.INTEGER
            % 2^2
            value = num2str(v.intValue(c));
        case jess.RU.LIST
            % 2^9
            vv = v.listValue(c);
            n = vv.size();
            value = '';
            for i = 1:n
                value = [ value jess_str_value(vv.get(i-1)) ' ' ];
            end
            value = strtrim( value );
        case jess.RU.LONG
            % 2^16
            value = num2str(v.longValue(c));
        case jess.RU.STRING
            % 2^1
            java_string = v.stringValue(c);
            value = java_string.toCharArray()';
        case jess.RU.SYMBOL
            % 2^0
            java_string = v.symbolValue(c);
            value = java_string.toCharArray()';
            if strcmp(value, 'FALSE')
                value = false;
            elseif strcmp(value, 'TRUE')
                value = true;
            end
        case jess.RU.NONE
            % 0
            value = '';
        otherwise
            % There doesn't seem to be a type value corresponding to the
            % method functionValue, nor methods corresponding to the type
            % values jess.RU.SLOT, jess.RU.MULTIVARIABLE, jess.RU.MULTISLOT
            % and jess.RU.LAMBDA.
            % These are just supersets:
            % jess.RU.LEXEME == jess.RU.SYMBOL | jess.RU.STRING
            % jess.RU.NUMBER == jess.RU.INTEGER | jess.RU.FLOAT |
            % jess.RU.LONG
            error(['Unknown Jess value type: ' num2str(v.type())]);
    end
end