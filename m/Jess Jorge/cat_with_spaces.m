function [expr] = cat_with_spaces(varargin)
% Example call:
%     cat_with_spaces This is a...
%         sample body of code.

    if ~iscellstr(varargin)
        error('Not all arguments are strings.');
    end
    
    expr = '';
    for i = 1:length(varargin)
        expr = [expr varargin{i} ' '];
    end
end