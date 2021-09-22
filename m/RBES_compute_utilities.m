function utilities = RBES_compute_utilities(sciences,costs)
%% RBES_compute_utilities.m
%
% Usage: results.utilities = RBES_compute_utilities(results.sciences,results.costs,used_params)
global params

weight_cost = params.WEIGHTS(2);
if length(sciences)>1
    u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
    au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
    utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
else
    utilities = [1];
end

utilities(isnan(utilities)) = 1;

end