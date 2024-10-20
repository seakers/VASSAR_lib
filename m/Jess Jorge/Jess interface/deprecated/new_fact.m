function [f] = new_fact(j, head, varargin)
% f: object of type jess.Fact
% j: jess.Rete object for Fact's Java constructor
% head: head of the new fact, as a string
% additional parameters: slot, value, slot, value, ...

    f = jess.Fact(head, j);
    for i = 1:2:(nargin-2)
        f.setSlotValue(varargin{i}, excel2jessValue(varargin{i+1}));
    end
    j.assertFact(f);
end