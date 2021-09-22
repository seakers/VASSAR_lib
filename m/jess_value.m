function [value] = jess_value(v)
% JESS_VALUE, v: jess.Value
% Transforms the return value of a call to jess.Rete.eval (a jess.Value
% object) into the equivalent Matlab value.
%
% Example call:
%     j = global_jess_engine();
%     
%     sample_exprs = {...
%         '(list 1 some-symbol "a string" 3.14)' ...
%         '(assert (sample fact))' ...
%         'TRUE' ...
%         };
%     
%     for e = sample_exprs
%         v = j.eval(e{1});
%         function_output = jess_value(v);
% 
%         jess_eval_expression = e{1}
%         value_returned = v.toStringWithParens()
%         function_output
%         output_class = class(function_output)
%     end

    j = global_jess_engine();
    c = j.getGlobalContext();
    
    switch v.type()
        % this pain is derived from these documents:
        % http://www.jessrules.com/docs/71/api/jess/Value.html , and
        % http://www.jessrules.com/docs/71/api/jess/RU.html
        % Jess' author promises to solve it with a Factory;
        % check jess.ValueFactory .
        case jess.RU.FACT
            % 2^4
            value = v.factValue(c);
        case jess.RU.FLOAT
            % 2^5
            value = v.floatValue(c);
        case jess.RU.FUNCALL
            % 2^6
            value = v.funcallValue(c);
        case jess.RU.INTEGER
            % 2^2
            value = v.intValue(c);
        case jess.RU.JAVA_OBJECT
            % 2^11
            value = v.javaObjectValue(c);
        case jess.RU.LIST
            % 2^9
            vv = v.listValue(c);
            n = vv.size();
            value = cell(1, n);
            for i = 1:n
                value{i} = jess_value(vv.get(i-1));
            end
        case jess.RU.LONG
            % 2^16
            value = v.longValue(c);
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
        case jess.RU.VARIABLE
            % 2^3
            value = v.variableValue(c);
        case jess.RU.NONE
            % 0
            value = [];
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