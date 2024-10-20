function utilities = RBES_compute_utilities2(results,weights)
%% RBES_compute_utilities.m
%
% Usage: = RBES_compute_utilities2(results,weights)
% global params
u_sciences = normalize_LIB(results.sciences);
au_costs = normalize_SIB(results.costs);
au_risks = normalize_SIB(results.programmatic_risks);
u_fairness = normalize_LIB(results.fairness);

utilities = [u_sciences au_costs au_risks u_fairness]*weights';
end

function norm = normalize_LIB(metric)
    norm =(metric - min(metric))./(max(metric)- min(metric)); 
end

function norm = normalize_SIB(metric)
    norm =(metric - min(metric))./(max(metric)- min(metric));
end
