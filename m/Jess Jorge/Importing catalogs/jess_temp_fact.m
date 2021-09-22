function [] = jess_temp_fact(varargin)
% head: head of the new temporary fact, as a string
% varargin: values of the fact
% To remove the temporary facts from the engine: jess_temp_fact(-9)

    persistent list
    if ~iscell(list), list = {}; end;
    
    if nargin == 1 &&...
       isnumeric(varargin{1}) &&...
       varargin{1} == -9
        remove_facts();
        return;
    end
    
    tokens = flatten_cell(varargin);
    jess({'assert (' tokens ')'});
    
    list = [list tokens(1)];
    
    function [] = remove_facts()
        cellmap(@(template) jess({'remove' template}), list); % the facts
        cellmap(@(template) jess_remove_template(template), list);
        list = {};
    end
end