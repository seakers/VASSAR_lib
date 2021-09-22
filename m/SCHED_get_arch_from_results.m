function a = SCHED_get_arch_from_results(results,archs,index)
%% SCHED_get_arch_from_results.m
% 
% Usage: a = SCHED_get_arch_from_results(results,index)
% Output:
% a.arch = results.archs(index,:)
% a.science = results.sciences(index)
% a.cost = results.costs(index)
% If approppriate:
% a.utility = results.utilities(index)
% a.pareto_ranking = results.pareto_rankings(index)

UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

a.arch = archs(index,:);
a.discounted_value = results.discounted_values(index);
a.data_continuity = results.data_continuities(index);

if UTILITIES
    a.utility = results.utilities(index);
end
if PARETO
    a.pareto_ranking = results.pareto_rankings(index);
end
end