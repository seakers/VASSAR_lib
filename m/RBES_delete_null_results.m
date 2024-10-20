function results2 = RBES_delete_null_results(results)
%% RBES_delete_null_results.m
% 
% usage: results = RBES_delete_null_results(results)
% 
% This function deletes archs for which costs equal to 0

UTILITIES = isfield(results,'utilities');
PARETO =isfield(results,'pareto_rankings');

n = 1;
for i = 1:length(results.costs)
    if ~results.costs(i) == 0
        results2.archs(n,:) = results.archs(i,:);
        results2.costs(n) = results.costs(i);
        results2.sciences(n) = results.sciences(i);
        if UTILITIES
            results2.utilities(n) = results.utilities(i);
        end
        if PARETO
            results2.pareto_rankings(n) = results.pareto_rankings(i);
        end
        n = n + 1;
    end
end
results2.costs = results2.costs';
results2.sciences = results2.sciences';
if UTILITIES
    results2.utilities = results2.utilities';
end
if PARETO
    results2.pareto_rankings = results2.pareto_rankings';
end

end