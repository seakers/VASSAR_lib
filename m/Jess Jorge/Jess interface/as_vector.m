function [ret] = as_vector(fun, varargin)
    ret = feval(fun, [varargin{:}]);
end