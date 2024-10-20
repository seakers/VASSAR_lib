function [t] = new_template(j, head, varargin)
% t: object of type jess.Deftemplate (I think)
% j: jess.Rete object for Deftemplate's Java constructor
% head: head of the new template, as a string
% additional parameters: slots.
% Use example:
%     new_template(j, 'Table', ...
%         'slot',         'Name', ...
%         'multislot',    'Columns' ...
%         );

    nil = jess.Funcall.NIL;

    t = jess.Deftemplate(jess_symbol(head), '', j);
    
    for i = 2:2:(nargin-2)
        if strcmp(varargin{i-1}, 'slot')
            t.addSlot(jess_symbol(varargin{i}), nil, 'ANY');
        elseif strcmp(varargin{i-1}, 'multislot')
            t.addSlot(jess_symbol(varargin{i}), nil, 'ANY');
        end
    end
    
    j.addDeftemplate(t);
end