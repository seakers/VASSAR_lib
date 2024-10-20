function cout = cellmap(fun, varargin)
% cellmap is like cellfun, except it traverses the nested cell arrays
% recursively. cout, thus, preserves the same structure as cin.
% Examples:
% cellmap(@(x) 2*x, {1 2 3})
% -> {2 4 6}
% cellmap(@(x) 2*x, {1 2 {{3} 4} 5})
% -> {2 4 {{6} 8} 10}
% cellmap(@(x,y) x+y, {1 2 {3}}, {4 5 {6}})
% -> {5 7 {9}}

    arguments = varargin;
    are_nested = cellfun(@iscell, arguments);
    
    if all(are_nested)
        % for each element of the cells:
        cout = cellfun(@(varargin)cellmap(fun,varargin{:}), ...
            arguments{:}, 'uniformOutput', false);
        
    elseif all(~are_nested)
        % arguments are scalars:
        cout = fun(arguments{:});
        
    else
        error('Nested cells of different structure in cellmap.')
    end
end