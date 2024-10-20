function [total_cost,nsat] = RBES_cost_estimate()
% global params
r = global_jess_engine();
%% Run cost estimate RBES
r.eval('(focus COST-ESTIMATION)');
r.run;
% Retrieve costs
    [total_cost,nsat] = RBES_retrieve_costs;
end