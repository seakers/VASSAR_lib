function [j] = global_jess_engine()
%Returns a new jess.Rete object
%   It is reset, can call Matlab, has a beep and a thread functions
%   defined, and a PART module defined.

    persistent g;    
    if isempty(g)
        g = jess.Rete();
    end
    j = g;
        
    persistent initializing;
    if isempty(initializing)
        initializing = true; % prevents infinite recursion
        initialize_jess_engine;
        initializing = false;
    end
end