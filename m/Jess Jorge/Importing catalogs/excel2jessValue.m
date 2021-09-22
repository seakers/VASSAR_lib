function [val] = excel2jessValue(cell)
% val: object of type jess.Value
% cell: matlab value as returned by xlsread in any of the cells of its
% output raw.
    nil = jess.Funcall.NIL;
    
    c = class(cell);
    if strcmp(c, 'char')
        % check for Excel #N/A, which comes as
        % 'ActiveX VT_ERROR: '
        if strcmp(cell, 'ActiveX VT_ERROR: ')
            val = nil;
        else
            val = jess.Value(cell, jess.RU.STRING);
        end
    elseif strcmp(c, 'double')
        % check for blank Excel cells, which come as NaN and
        % have class 'double'
        if isnan(cell)
            val = nil;
        else
            val = jess.Value(cell, jess.RU.FLOAT);
        end
    elseif strcmp(c, 'logical')
        val = jess.Value(cell);
    else
        error(['treat excel cells of class ' c '!']);
    end
end