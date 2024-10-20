function [val] = assign(var_name, val)
    assignin('caller', var_name, val);
end