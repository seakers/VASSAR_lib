function these_results = PACK_convergence(these_results,archs)
persistent old_results
if isempty(old_results)
    old_results = these_results;
end
[these_results.max_utility,these_results.index_best_arch] = max(these_results.utilities);
these_results.best_arch = archs(these_results.index_best_arch,:);
these_results.max_science = max(these_results.sciences);
these_results.min_cost = max(these_results.costs);
these_results.narchs = size(archs,1);
these_results.avg_science = mean(these_results.sciences);
these_results.avg_cost = mean(these_results.costs);
these_results.avg_utility = mean(these_results.utilities);

fprintf('Best arch = %d with max utility = %f. Max science = %f. Min cost = %f\n',these_results.index_best_arch,these_results.max_utility,these_results.max_science,these_results.min_cost);
fprintf('Best arch: %s\n',PACK_arch_to_str(archs(these_results.index_best_arch,:)));
fprintf('Average science = %f, average cost = %f, average utility = %f\n',these_results.avg_science,these_results.avg_cost,these_results.avg_utility);

if isfield(old_results,'max_science')
    these_results.delta_max_science = these_results.max_science - old_results.max_science;
    these_results.delta_max_utility = these_results.max_utility - old_results.max_utility;
    these_results.delta_min_cost = these_results.min_cost - old_results.min_cost;
    these_results.delta_avg_science = these_results.avg_science - old_results.avg_science;
    these_results.delta_avg_utility = these_results.avg_utility - old_results.avg_utility;
    these_results.delta_avg_cost = these_results.avg_cost - old_results.avg_cost;
    these_results.delta_best_arch = isequal(these_results.best_arch,old_results.best_arch);
    fprintf('Old best arch = %d with max utility = %f. Old max science = %f. Old min cost = %f\n',old_results.index_best_arch,old_results.max_utility,old_results.max_science,old_results.min_cost);

end





old_results = these_results;
end