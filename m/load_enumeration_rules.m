function load_enumeration_rules
%% load_enumeration_rules.m
global params
r = global_jess_engine();
if strcmp(params.MODE,'SELECTION') 
    r.eval(['(bind ?enumeration_rules_clp "' params.enumeration_rules_selection_clp '")']);
elseif strcmp(params.MODE,'PACKAGING')
    r.eval(['(bind ?enumeration_rules_clp "' params.enumeration_rules_packaging_clp '")']);
elseif strcmp(params.MODE,'SCHEDULING')
    r.eval(['(bind ?enumeration_rules_clp "' params.enumeration_rules_scheduling_clp '")']);
elseif strcmp(params.MODE,'ASSIGNING')
    r.eval(['(bind ?enumeration_rules_clp "' params.enumeration_rules_assigning_clp '")']);
end

end