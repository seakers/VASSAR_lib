function load_cost_estimation_rules
%% load_cost_estimation_rules.m
global params
r = global_jess_engine();
if strcmp(params.BUS,'STANDARD')
    r.eval(['(bind ?cost_estimation_rules_clp "' params.cost_estimation_rules_standard_bus_clp '")']);
elseif strcmp(params.BUS,'DEDICATED')
    r.eval(['(bind ?cost_estimation_rules_clp "' params.cost_estimation_rules_clp '")']);
end

r.eval('(batch ?cost_estimation_rules_clp)');
end