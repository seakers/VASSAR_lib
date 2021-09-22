function load_mass_budget_rules
%% load_mass_budget_rules.m
global params
r = global_jess_engine();
r.eval(['(bind ?mass_budget_rules_clp "' params.mass_budget_rules_clp '")']);
r.eval('(batch ?mass_budget_rules_clp)');

r.eval(['(bind ?mass_budget_rules_clp "' params.adcs_design_rules_clp '")']);
r.eval('(batch ?mass_budget_rules_clp)');

r.eval(['(bind ?mass_budget_rules_clp "' params.propulsion_design_rules_clp '")']);
r.eval('(batch ?mass_budget_rules_clp)');

r.eval(['(bind ?mass_budget_rules_clp "' params.subsystem_mass_budget_rules_clp '")']);
r.eval('(batch ?mass_budget_rules_clp)');

r.eval(['(bind ?mass_budget_rules_clp "' params.deltaV_budget_rules_clp '")']);
r.eval('(batch ?mass_budget_rules_clp)');

end