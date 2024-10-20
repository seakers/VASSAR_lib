function [names] = get_basic_units()
% Adds syms representing common units to the workspace of the caller
% function. All are defined in terms of basic syms which are persistent:
% This means one can pass units between two different functions that call
% "import_units" and said units will recognize each other. In this sense,
% one can program as if they were just part of the Matlab language :)

    persistent N W s V rad dollars
    names = who();
    
    if isempty(eval(names{1}))
        syms(names{:}, 'positive');
    end
    
    if nargout == 0
        for i = 1:length(names)
            assignin('caller', names{i}, eval(names{i}));
        end
    end
end