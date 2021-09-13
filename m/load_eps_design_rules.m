function load_eps_design_rules
%% load_eps_design_rules.m
global params
r = global_jess_engine();
r.eval(['(bind ?eps_design_rules_clp "' params.EPS_design_rules_clp '")']);
r.eval('(batch ?eps_design_rules_clp)');
end