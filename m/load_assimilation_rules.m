function load_assimilation_rules
%% load_assimilation_rules.m
% Unused as of Dec 3th 2011 
% Daniel Selva
global params
r = global_jess_engine();
r.eval(['(bind ?assimilation_clp_file "' params.assimilation_rules_clp '")']);
r.eval('(batch ?assimilation_clp_file)');
end