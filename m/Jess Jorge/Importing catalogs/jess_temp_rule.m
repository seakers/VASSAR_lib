function [] = jess_temp_rule(varargin)
% head: head of the new temporary rule, as a string
% varargin: rule body
% To remove the temporary rules from the engine: jess_temp_rule(-9)

    persistent list
    if ~iscell(list), list = {}; end;

    if nargin == 1 &&...
       isnumeric(varargin{1}) &&...
       varargin{1} == -9
        remove_rules();
        return;
    end
    
    tokens = flatten_cell(varargin);
    jess([{'defrule'} tokens]);
    
    list = [list tokens(1)];
    
    function [] = remove_rules()
        cellmap(@(rule) jess_remove_rule(rule), list);
        list = {};
    end
end