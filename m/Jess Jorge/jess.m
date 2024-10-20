function [ret] = jess(varargin)
% Example call:
%     jess printout t (jess-version-string) crlf...
%         "2 x 3 = " (* 2 3) crlf;

    j = global_jess_engine();
    
    expr = cat_with_spaces(varargin{:});
    
    ret = jess_value(j.eval(['(' expr ')']));
end