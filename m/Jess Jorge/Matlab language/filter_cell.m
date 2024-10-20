function cout = filter_cell(cin, predicate, varargin)
% Examples:
% filter_cell(num2cell(1:5), @(x) x>3)
% -> {4 5}
% filter_cell(num2cell(1:3), @(~,s) strcmp('t',s), {'t' 'f' 't'})
% -> {1 3}
    cout = cin(cellfun(predicate, cin, varargin{:}));
end