function [expr] = cat_with_spaces(varargin)
% Example calls:
%     cat_with_spaces This is a...
%         sample body of text.
%     cat_with_spaces({'This' {'is' 'equivalent'}})

    % flatten nested cell arrays
    varargin = flatten_cell(varargin);
    
    % convert to string and append spaces
    expr = cellfun(@(token) [num2str(token) ' '], varargin, 'uni', false);
    
    % concatenate all
    expr = horzcat(expr{:});
end