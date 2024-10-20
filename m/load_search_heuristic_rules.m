function load_search_heuristic_rules
%% load_search_heuristic_rules.m

global params
r = global_jess_engine();

% if strcmp(params.MODE,'SELECTION') 
%     r.eval(['(bind ?search_heuristic_rules_clp "' params.search_heuristic_rules_selection_clp '")']);
% elseif strcmp(params.MODE,'PACKAGING')
%     r.eval(['(bind ?search_heuristic_rules_clp "' params.search_heuristic_rules_packaging_clp '")']);
% elseif strcmp(params.MODE,'SCHEDULING')
%     r.eval(['(bind ?search_heuristic_rules_clp "' params.search_heuristic_rules_scheduling_clp '")']);
% elseif strcmp(params.MODE,'ASSIGNING')
%     r.eval(['(bind ?search_heuristic_rules_clp "' params.search_heuristic_rules_assigning_clp '")']);
% end
r.eval(['(bind ?search_heuristic_rules_clp "' params.search_heuristic_rules_adhoc_clp '")']);
r.eval('(batch ?search_heuristic_rules_clp)');




end