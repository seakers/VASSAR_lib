function load_explanation_rules
%% load_explanation_rules.m
global params
r = global_jess_engine();
r.eval(['(bind ?explanation_clp_file "' params.explanation_rules_clp '")']);
r.eval('(batch ?explanation_clp_file)');

return