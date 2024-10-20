function [ret] = lambda(str, varargin)
    ret = feval(str2func(str), varargin{:});
end