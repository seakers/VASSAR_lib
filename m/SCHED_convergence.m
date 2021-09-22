function these_results = SCHED_convergence(these_results,archs)
persistent old_results
if isempty(old_results)
    old_results = these_results;
end
[these_results.max_utility,these_results.index_best_arch] = max(these_results.utilities);
these_results.best_arch = archs(these_results.index_best_arch,:);
these_results.max_discounted_value = max(these_results.discounted_values);
these_results.max_data_continuity = max(these_results.data_continuities);
these_results.narchs = size(archs,1);
these_results.avg_discounted_value = mean(these_results.discounted_values);
these_results.avg_data_continuity = mean(these_results.data_continuities);
these_results.avg_utility = mean(these_results.utilities);

fprintf('Best arch = %d with max utility = %f. Max DV = %f. Max DC = %f\n',these_results.index_best_arch,these_results.max_utility,these_results.max_discounted_value,these_results.max_data_continuity);
fprintf('Best arch: %s\n',SCHED_arch_to_str(archs(these_results.index_best_arch,:)));
fprintf('Average DV = %f, average DC = %f, average utility = %f\n',these_results.avg_discounted_value,these_results.avg_data_continuity,these_results.avg_utility);

if isfield(old_results,'max_discounted_value')
    these_results.delta_max_discounted_value = these_results.max_discounted_value - old_results.max_discounted_value;
    these_results.delta_max_utility = these_results.max_utility - old_results.max_utility;
    these_results.delta_max_data_continuity = these_results.max_data_continuity - old_results.max_data_continuity;
    these_results.delta_avg_discounted_value = these_results.avg_discounted_value - old_results.avg_discounted_value;
    these_results.delta_avg_utility = these_results.avg_utility - old_results.avg_utility;
    these_results.delta_avg_data_continuity = these_results.avg_data_continuity - old_results.avg_data_continuity;
    these_results.delta_best_arch = isequal(these_results.best_arch,old_results.best_arch);
    fprintf('Old best arch = %d with max utility = %f. Old max DV = %f. Old max DC = %f\n',old_results.index_best_arch,old_results.max_utility,old_results.max_discounted_value,old_results.max_data_continuity);

end





old_results = these_results;
end